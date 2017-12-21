//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/9/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    var coreDataConvenience = CoreDataConvenience()
    
    var selectedPinLongitude: Double?
    var selectedPinLatitude: Double?
    
    // Static keys to access values in UserDefaults
    static let MapCenterLongitudeKey = "MapCenterLongitude"
    static let MapCenterLatitudeKey = "MapCenterLatitude"
    static let ZoomLatitudeDeltaKey = "ZoomLatitudeDelta"
    static let ZoomLongitudeDeltaKey = "ZoomLongitudeDelta"
    static let MapCenterCoordinateKey = "MapCenterCoordinate"
    static let ZoomLevelKey = "ZoomLevel"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the navigation bar
        self.navigationController?.navigationBar.isHidden = true
        
        // get the stack
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let stack = appDelegate.stack
        
        // create a fetch request to grab all the pins
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        coreDataConvenience.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        configureMapView()
        
        mapView.delegate = self
    }
    
    // hide the navigation bar when a user comes back to the map view
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation bar
        navigationController?.navigationBar.isHidden = true
        
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // Method to configure the map view to the last 'viewed' state
    func configureMapView() {
        
        // get any previously placed pins and add them to the map
        getSavedPins()
        
        // Add a UILongGestureRecognizer to the map to allow for 'touch and hold' to drop a pin
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.5
        
        // add the passed in Gesture Recognizer to the mapp
        mapView.addGestureRecognizer(gestureRecognizer)
        
        // set the center and zoom level of the map if a user has previously visited the map view
        // otherwise, just show the mapview as regular
        if let mapCenterLatitude = UserDefaults.standard.value(forKey: MapViewController.MapCenterLatitudeKey) as? Double,
            let mapCenterLongitude = UserDefaults.standard.value(forKey: MapViewController.MapCenterLongitudeKey) as? Double,
            let zoomLatitudeDelta = UserDefaults.standard.value(forKey: MapViewController.ZoomLatitudeDeltaKey) as? Double,
            let zoomLongitudeDelta = UserDefaults.standard.value(forKey: MapViewController.ZoomLongitudeDeltaKey) as? Double {
            
            let mapCenterCoordinate = CLLocationCoordinate2D(latitude: mapCenterLatitude, longitude: mapCenterLongitude)
            let zoom = MKCoordinateSpan(latitudeDelta: zoomLatitudeDelta, longitudeDelta: zoomLongitudeDelta)
            
            mapView.region = MKCoordinateRegion(center: mapCenterCoordinate, span: zoom)
        }
    }
    
    // 'Selector' method for when a user taps and holds on the map to drop a pin
    @objc func addAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // only add a pin after the user has stopped touching the screen
        // this prevents us from saving multiple of the same pin
        if gestureRecognizer.state != .ended { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annoation = MKPointAnnotation()
        annoation.coordinate = coordinate
        mapView.addAnnotation(annoation)

        if let fetchedResultsController = coreDataConvenience.fetchedResultsController {
            // save the 'pin' to CoreData
            let pin = Pin(latitdue: coordinate.latitude, longitude: coordinate.longitude, context: fetchedResultsController.managedObjectContext)
            print("Just created and saved a Pin!: \(pin)")
            
            
            // I had to manually call the save() method since when I was creating the Pin entity it wasn't being added to core data
            // so when i closed the app and re-opened it, it would have the new pins i added previously
            // even though I set up autoSave() and the saving when the app goes to the background, etc. etc.
            // this was the only thing that I could find to work
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let stack = appDelegate.stack
            stack.save()
        }
    }
    
    // Method to grab the (potentially) saved pins and add them to the map view
    func getSavedPins() {
        
        if let pins = coreDataConvenience.fetchedResultsController?.fetchedObjects as? [Pin] {
            let annotations = pins.map { (pin) -> MKPointAnnotation in
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annoation = MKPointAnnotation()
                annoation.coordinate = coordinate
                return annoation
            }
            // add the annotations to the mapview
            mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: - MapView Delegate Methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Save the maps center and zoom level in user defaults
        let mapCenterCoordinate = mapView.centerCoordinate
        let mapCenterLongitude = mapCenterCoordinate.longitude
        let mapCenterLatitdue = mapCenterCoordinate.latitude
        let zoomLevel = mapView.region.span
        let zoomLatitudeDelta = zoomLevel.latitudeDelta
        let zoomLongitudeDelta = zoomLevel.longitudeDelta
        
        UserDefaults.standard.set(mapCenterLongitude, forKey: MapViewController.MapCenterLongitudeKey)
        UserDefaults.standard.set(mapCenterLatitdue, forKey: MapViewController.MapCenterLatitudeKey)
        UserDefaults.standard.set(zoomLatitudeDelta, forKey: MapViewController.ZoomLatitudeDeltaKey)
        UserDefaults.standard.set(zoomLongitudeDelta, forKey: MapViewController.ZoomLongitudeDeltaKey)
        
    }
    
    // Create a view with a Pin added where the user taps and holds
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // take the user to the photo album view of the selected pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let pin = view.annotation else {
            print("Could not get selected Pin!")
            return
        }
        
        selectedPinLatitude = pin.coordinate.latitude
        selectedPinLongitude = pin.coordinate.longitude
        
        // now deselect the pin so when we come back, its not already selected
        mapView.deselectAnnotation(pin, animated: true)
        
        performSegue(withIdentifier: "mapViewToPhotoAlbumSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // grab the pin from the fetch request result and then create another fetch request grabbing all the photos
        // corresponding to that pin by using an NSPredicate and then set the Photo Albums fetch request
        // to the new fetch request and set the selected pin to the Photo Albums Pin
        
        guard let selectedPinLatitude = selectedPinLatitude, let selectedPinLongitude = selectedPinLongitude else {
            print("Could not unwrap the selected Pins latitude or longitude!")
            return
        }
        
        // get the stack
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let stack = appDelegate.stack
        
        // create a compound predicate to be able to filter the fetch result to find a specific Pin
        let latitudePredicate = NSPredicate(format: "latitude = %@", argumentArray: [selectedPinLatitude])
        let longitudePredicate = NSPredicate(format: "longitude = %@", argumentArray: [selectedPinLongitude])
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate])
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = compoundPredicate
        
        coreDataConvenience.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // grab the pin that is returned (if any, it should always return something) and set the photoalbums pin to it
        if let pin = coreDataConvenience.fetchedResultsController?.fetchedObjects?.first as? Pin,
            let photoAlbumViewController = segue.destination as? PhotoAlbumViewController {
            
            photoAlbumViewController.finalInit(pin: pin, appDelegate: appDelegate)
        }
    }
}
