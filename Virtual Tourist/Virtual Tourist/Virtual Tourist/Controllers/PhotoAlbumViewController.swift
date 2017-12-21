//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/10/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pin: Pin?
    var appDelegate: AppDelegate?
    var coreDataConvenience = CoreDataConvenience()
    
    
    // IBAction to trigger a new api call to 'update' the photo album for a given pin
    @IBAction func newCollectionButtonWasPressed(_ sender: Any) {
        
        if let pin = pin, let stack = appDelegate?.stack,
            let fetchedResultsController = coreDataConvenience.fetchedResultsController {
            newCollectionButton.isEnabled = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            // delete the previous photo album from core data in the background while we fetch new photos
            stack.performBackgroundBatchOperation { (workerContext) in
                if let photos = fetchedResultsController.fetchedObjects as? [Photo] {
                    // have to run core data operations on the main thread for thread safe operations
                    DispatchQueue.main.async {
                        let _ = photos.map { (photo) in
                            fetchedResultsController.managedObjectContext.delete(photo)
                            stack.save()
                        }
                    }
                }
                print("Finished background batch deletion!")
            }
            startFlickrPhotosAPICall(pin: pin)
        }
    }
    
    // custom final initializer to initialize any final properties
    func finalInit(pin: Pin, appDelegate: AppDelegate) {
        self.pin = pin
        self.appDelegate = appDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    func configureView() {
        // unhide the navigation bar
        self.navigationController?.navigationBar.isHidden = false
        
        // hide the activity indicator but also make sure to bring it to the front so when we unhide it and
        // start animating it, it actually shows
        activityIndicator.isHidden = true
        view.bringSubview(toFront: activityIndicator)
        
        // configure the flow layout of the collection view
        let space: CGFloat = 1.0
        let dimensionHeight = (view.frame.size.height - (2 * space)) / 3.0
        let dimensionWidth = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
        
        // create a fetch request to grab all of the photos associated with the passed in pin
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        // grab the stack from the pased in appDelegate object and the pin
        guard let stack = appDelegate?.stack, let pin = pin else {
            print("Could not grab the stack and/or the pin from the passed in objects!")
            return
        }
        
        // create a predicate to get all the photos specific to the pin passed in
        let pinPredicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        fetchRequest.predicate = pinPredicate
        
        coreDataConvenience.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        mapView.delegate = self
        configureMapView()
        configureCollectionView(pin: pin)
    }
    
    // method to configure the collection view
    func configureCollectionView(pin: Pin) {
        
        // if the pin already has photos associated with it, no need to download new ones right now
        // otherwise, start the api call to get photos associated with the passed in Pin
        // Also, if know that there are already downloaded images, we can set the 'new colleciton' button to be enabled, otherwise disable it
        if let fetchedResultsController = coreDataConvenience.fetchedResultsController,
            fetchedResultsController.fetchedObjects?.count == 0 {

            newCollectionButton.isEnabled = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            startFlickrPhotosAPICall(pin: pin)
        }
        else {
            newCollectionButton.isEnabled = true
        }
        
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
    }
    
    // present an alert letting the user know something went wrong!
    func presentAlert(error: String) {
        let alertController = UIAlertController(title: "OOPS!", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // method to configure the collection view
    func startFlickrPhotosAPICall(pin: Pin) {
        
        // select a random page everytime we call the api
        let randomPage = Int(arc4random_uniform(UInt32(40))) + 1
    
        // Start the api call to get the photos that will populate the collection view
        APIClient.sharedInstance().getPhotosByLatitudeAndLongitude(latitude: pin.latitude, longitude: pin.longitude, randomPage: randomPage) { (photos, error) in
            
            // make sure there wasn't an error returned
            guard (error == nil) else {
                print("There was an error with the call: \(error!)")
                self.presentAlert(error: "\(error!)")
                return
            }
                        
            // convert and save the photo data to core data
            if let photos = photos {
                self.savePhotosToCoreData(photos: photos, pin: pin)
            }
        }
    }
    
    // method to save the passed back photo data into Photo managed objects
    func savePhotosToCoreData(photos: [NSData], pin: Pin) {
        
        if let fetchedResultsController = coreDataConvenience.fetchedResultsController {
           
            // have to run core data operations on the main thread for thread safe operations
            DispatchQueue.main.async {
                let _ = photos.map { (photoData) in
                    // save the photoData as a 'Photo' managed object
                    let photo = Photo(imageData: photoData, context: fetchedResultsController.managedObjectContext)
                    photo.pin = pin
                    print("Just created and saved a photo!: \(photo)")
                }
                
                // manually save the data into core data
                if let stack = self.appDelegate?.stack {
                    stack.save()
                }
                
                // update the fetched results controller with new data
                self.coreDataConvenience.executeSearch()
            
                // finally reload the collection view data and enable the 'new collection' button
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.newCollectionButton.isEnabled = true
                self.photoAlbumCollectionView.reloadData()
            }
        }
    }
}

// MARK: - MapViewDelegate Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func configureMapView() {
        
        // unwrap the Pin that was passed in and set the mapviews location and pin
        if let pin = pin {
            let latitudeDelta = 0.01
            let longitudeDelta = 0.01
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource and Delegate

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // delete the photo from the fetched results controller and update the collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // have to run core data operations on the main thread for thread safe operations
        DispatchQueue.main.async {
            if let fetchedResultsController = self.coreDataConvenience.fetchedResultsController, fetchedResultsController.fetchedObjects?.count != 0,
                let photo = fetchedResultsController.object(at: indexPath) as? Photo,
                let stack = self.appDelegate?.stack {
                
                fetchedResultsController.managedObjectContext.delete(photo)
                
                // save the stack with the updated deleted picture
                stack.save()
                
                // update the fetched results controller to represent the most recent deletion
                self.coreDataConvenience.executeSearch()
                
                collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let fetchedResultsController = coreDataConvenience.fetchedResultsController, let count = fetchedResultsController.fetchedObjects?.count, count != 0 {
            return count
        }

        // max number of items if there are no fetched objects
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        // if there are no fetched objects yet (pin hasn't downloaded any photos yet)
        // set a 'placeholder' image in the cell until they are downloaded
        if let fetchedResultsController = coreDataConvenience.fetchedResultsController,
            fetchedResultsController.fetchedObjects?.count != 0,
            let photo = fetchedResultsController.object(at: indexPath) as? Photo {
            
            if let data = photo.imageData {
                let imageData = Data(referencing: data)
                cell.imageView.image = UIImage(data: imageData)
            }
        } else {
            cell.imageView.image = UIImage(named: "Placeholder")
        }
        
        return cell
    }
}

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
