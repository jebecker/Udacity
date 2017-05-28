//
//  MainMemeMeViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 5/28/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class MainMemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Declare outlets for all of my UI Elements I will need to be able to access 
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var socialShareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
  
    // Declare IBActions for the buttons on the screen
    @IBAction func shareButtonWasPressed(_ sender: Any) {
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
    }
    
    // IBAction that will present the camera album to the user to allow them to pick the picture they want to meme
    @IBAction func albumButtonPressed(_ sender: Any) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call the configureUI method
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check whether the device has a camera, if not, disable the camera button
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = false
        }
    }
    
    
    // custom method to configure any UI elements in the view
    func configureUI() {
        
        // set a list of properties for the text atributes
        let memeTextAtrributes = [NSStrokeColorAttributeName: UIColor.black,
                                  NSForegroundColorAttributeName: UIColor.white]
        
        // set the top and bottom text field attributes to the dictionary of attributes we set above
        topTextField.defaultTextAttributes = memeTextAtrributes
        bottomTextField.defaultTextAttributes = memeTextAtrributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
    }
}
