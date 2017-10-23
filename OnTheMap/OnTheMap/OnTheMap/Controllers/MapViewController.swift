//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/15/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapViewDelegate: MapViewDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - IBOutlets/IBActions
    @IBOutlet weak var mapView: MKMapView!
    
    // method to bring the user to the information posting view controller so they manually add pins to the map
    @IBAction func addPinButtonWasPressed(_ sender: UIBarButtonItem) {
        let informationPostingNavigationController = storyboard?.instantiateViewController(withIdentifier: "informationPostingNavigationController") as! UINavigationController
        present(informationPostingNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonWasPressed(_ sender: UIBarButtonItem) {
        configureMapView()
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        // Logout
        APIClient.sharedInstance().logout { (result, error) in
            guard error == nil else {
                self.displayAlert(message: "Sorry, but we could no log you out at this time. Please try again.")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
    }
    
    func configureMapView() {

        APIClient.sharedInstance().getStudentInformation() { (result, error) in
            guard result != nil else {
                self.displayAlert(message: "Could not get student information from the server. Please try again!")
                return
            }
                
            self.mapViewDelegate = MapViewDelegate(mapView: self.mapView, students: self.appDelegate.students!)
            self.mapViewDelegate?.addAnnotations()
            self.mapView.delegate = self.mapViewDelegate
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - MKMapViewDelegate class
class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    // declare properties
    var mapView: MKMapView
    var students: [Student]
    var annotations = [MKPointAnnotation]()
    
    // custom init
    init(mapView: MKMapView, students: [Student]) {
        self.mapView = mapView
        self.students = students
    }
    
    func addAnnotations() {
        
        // loop through the array of students to grab their locations coordinates and student info
        for student in students {
            let latitude = CLLocationDegrees(student.latitude)
            let longitude = CLLocationDegrees(student.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // grab the other student information needed
            let firstName = student.firstName
            let lastName = student.lastName
            let mediaURL = student.mediaURL
            
            // now create the annotation we will be adding to the array of annotations
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = coordinate
            annotaion.title = "\(firstName) \(lastName)"
            annotaion.subtitle = mediaURL
            
            annotations.append(annotaion)
        }
        
        // add the annotations to the map so we can display them
        mapView.addAnnotations(annotations)
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


