//
//  InformationMapViewController.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/16/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class InformationMapViewController: UIViewController {
    
    // MARK: - IBOutlets/IBActions
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    // MARK: - Properties
    var user: User?
    var coordinate: CLLocationCoordinate2D?
    var location: String?
    var mediaURL: String?
    var informationMapViewDelegate: InformationMapViewDelegate?
    
    @IBAction func finishedButtonWasPressed(_ sender: Any) {
        // start the student location POST method
        startStudentLocationPOSTMethod()
    }
    
    // custom final init
    func finalInit(user: User, coordinate: CLLocationCoordinate2D, location: String, mediaURL: String) {
        self.user = user
        self.coordinate = coordinate
        self.location = location
        self.mediaURL = mediaURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationMapViewDelegate = InformationMapViewDelegate(mapView: mapView, annotation: createAnnotation())
        
        // configure the map view
        configureMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // open the pin the user dropped so they can see the details
        mapView.selectAnnotation(mapView.annotations.first!, animated: true)
    }
    
    func configureMapView() {
        informationMapViewDelegate?.setRegion()
        informationMapViewDelegate?.addAnnotation()
        mapView.delegate = informationMapViewDelegate
    }
    
    // method to create an annotation based off the user information passed in
    func createAnnotation() -> MKPointAnnotation {
        guard let user = user,
            let coordinate = coordinate,
            let mediaURL = mediaURL else {
                print("Could not unwrap properties to create an annotation")
                return MKPointAnnotation()
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(user.firstName) \(user.lastName)"
        annotation.subtitle = mediaURL
        
        return annotation
    }
    
    // MARK: - Student Location POST helper method
    func startStudentLocationPOSTMethod() {
        
        guard let userId = user?.userId,
            let firstName = user?.firstName,
            let lastName = user?.lastName,
            let mediaURL = mediaURL,
            let latitude = coordinate?.latitude,
            let longitude = coordinate?.longitude,
            let location = location
            else {
                displayError(error: "Could not unwrap properties passed in")
                return
        }
        
        APIClient.sharedInstance().postStudentLocation(userId: userId, firstName: firstName, lastName: lastName, mediaURL: mediaURL, latitude: latitude, longitude: longitude, location: location) { (result, error) in
            // make sure we don't have an error
            guard (error == nil) else {
                self.displayError(error: "Sorry, but we could not successfully post your location")
                return
            }
            
            // dismiss the information posting view 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Display error
    func displayError(error: String) {
        let alert = UIAlertController(title: "OOPS!", message: error, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate class
class InformationMapViewDelegate: NSObject, MKMapViewDelegate {
    
    // declare properties
    var mapView: MKMapView
    let annotation: MKPointAnnotation
    
    // custom init
    init(mapView: MKMapView, annotation: MKPointAnnotation) {
        self.mapView = mapView
        self.annotation = annotation
    }
    
    // Method to add the annotation to the map view
    func addAnnotation() {
        mapView.addAnnotation(annotation)
    }
    
    // open annotation on zoom
    func openAnnotation() {
        mapView.selectAnnotation(mapView.annotations.first!, animated: true)
    }
    
    // Method to set and zoom into the region the user typed in
    func setRegion() {
        let latitudeDelta = 0.05
        let longitudeDelta = 0.05
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    // Create a view with a "right callout accessory view"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // delegate method to respond to taps in the annotation view to open safari to the annotations mediaURL (i.e. subtitle)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}

