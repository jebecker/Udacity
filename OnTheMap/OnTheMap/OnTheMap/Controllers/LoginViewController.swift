//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/14/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties/IBOutlest/IBAction
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var noAccountStackView: UIStackView!
    @IBOutlet weak var userCapturedStackView: UIStackView!
    @IBOutlet weak var udacityLogoImageView: UIImageView!
    @IBOutlet weak var debugLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        
        hideKeyboard()
        
        // make sure that the username and password text fields have data in them
        if let username = usernameTextField.text,
            let password = passwordTextField.text,
            (username != "" && password != "") {
            
            APIClient.sharedInstance().establishUdacitySession(username: username, password: password) { (result, error) in
                guard (error == nil) else {
                    self.displayError(errorString: "Could not establish a UDACITY session!")
                    return
                }
                
                guard let userId = result else {
                    self.displayError(errorString: "Could not retrieve USERID from the udaicty session response")
                    return
                }
                
                // complete the login
                self.completeLogin(userId: userId)
            }
        } else {
            displayError(errorString: "You must have BOTH a username AND a password in order to login!")
        }
        
        
    }
    
    @IBAction func signUpButtonWasPressed(_ sender: Any) {
        hideKeyboard()
        // open the mediaURL of the student in SAFARI
        let app = UIApplication.shared
        app.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    func hideKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLabel.text = ""
        
        subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        unsubscribeToKeyboardNotifications()
    }
    
    // complete the login process and present the main tab bar navigation controller
    func completeLogin(userId: String) {
        
        performUIUpdatesOnMain {
            self.debugLabel.text = ""
        }
        
        // Grab the logged in users first name and last name
        APIClient.sharedInstance().getUdacityUserInformation(userId: userId) { (result, error) in
            guard (error == nil) else {
                self.displayError(errorString: "Could not get logged in users information")
                return
            }
            
            guard let user = result else {
                self.displayError(errorString: "Could not retrieve the custom USER struct from the Udacity users API")
                return
            }
            // save the user and show the main tab bar controller
            self.appDelegate.user = user
            self.showMainTabBarController()
        }
    }
    
    // method to instantiate main tab bar controller after a successful login
    func showMainTabBarController() {
        // instantiate the navigation controller of the tab bar controller and bring user inside the app
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
        present(mainTabBarController, animated: true, completion: nil)
    }
    
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
        if passwordTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // adjust the view back to its original position
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return (keyboardSize.cgRectValue.height - 175)
    }

}

// extension to handle UI
extension LoginViewController {
    
    func setUIEnabled(enabled: Bool) {
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
            signUpButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
            signUpButton.alpha = 0.5
        }
    }
    
    // display the alert view controller to the user
    func displayError(errorString: String?) {
        let alert = UIAlertController(title: "Oops!", message: errorString, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}
