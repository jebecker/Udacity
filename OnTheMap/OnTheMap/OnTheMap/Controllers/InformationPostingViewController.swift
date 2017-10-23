//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/16/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
   
    // MARK: - IBOutlets
    @IBOutlet weak var userInformationStackView: UIStackView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var geocoder = CLGeocoder()
    var coordinate = CLLocationCoordinate2D()
    
    // MARK: - IBActions
    
    // IBAction to bring the user back to the tab bar controller
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        hideTextFields()
        performUIUpdatesOnMain {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func findLocationButtonWasPressed(_ sender: Any) {
        
        hideTextFields()
        if let location = locationTextField.text,
            let link = linkTextField.text,
            (location != "" && link != "") {
            
            // DO FORWARD GEOCODE HERE and if succesfful take user to the informationMapView
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                // process the response
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
            
            // start the activity indicator showing the user that we are working in the background
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
        } else {
            displayError(message: "You must enter a location AND a link in order to find a location!")
        }
        
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? InformationMapViewController,
            let user = appDelegate.user,
            let location = locationTextField.text,
            let mediaURL = linkTextField.text {
            destinationViewController.finalInit(user: user, coordinate: self.coordinate, location: location, mediaURL: mediaURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK - Error UI
    func displayError(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CLear UI
    func hideTextFields() {
        locationTextField.resignFirstResponder()
        linkTextField.resignFirstResponder()
    }
    
    // MARK: - CoreLocation Geocoder helper methods
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // make sure there wasn't an error returned from the geocoder method
        guard error == nil else {
            displayError(message: "Sorry, we could not find your location, please try again!")
            return
        }
        
        var location: CLLocation?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first?.location
        }
        
        if let location = location {
            let coordinate = location.coordinate
            self.coordinate = coordinate
            
            // stop the activity indicator
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            
            // segue to the information map view
            performSegue(withIdentifier: "informationPostingToInformationMapViewSegue", sender: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        performUIUpdatesOnMain {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Set up the notification center to start observiing for the keyboard to either show/hide it
    
    func subscribeToKeyboardNotifications() {
        
        // Add an observer to the notification center to fire the 'keyboardWillShow' method
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        // Add an observer for the keyboardWillHide method in order to bring the view back to its original position
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        
        // Remove the observer in the Notification center that controls the .UIKeyboardWillShow/hide notification
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Custom Methods to show and hide the keyboard corerctly
    
    @objc func keyboardWillShow(notification: Notification) {
        // adjust the view for the keyboard so nothing gets cut off for the bottom text field only
        // depending on the orientation of the device, adjust the amount the screen shifts
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            view.frame.origin.y = (-getKeyboardHeight(notification: notification) + 50)
        case .landscapeRight:
            view.frame.origin.y = (-getKeyboardHeight(notification: notification) + 50)
        case .portrait:
            view.frame.origin.y = (-getKeyboardHeight(notification: notification) + 175)
        default:
            break
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        // adjust the view back to its original position
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return (keyboardSize.cgRectValue.height)
    }
    
}
