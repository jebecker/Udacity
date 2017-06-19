//
//  MainMemeMeViewController.swift
//  MemeMe
//
//  Created by Jayme Becker on 5/28/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class MainMemeMeViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    // Declare outlets for all of my UI Elements I will need to be able to access 
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var socialShareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBarItems: UINavigationItem!
    
    // Declare custom variable for the image picker delegate
    var imagePickerDelegate: MemeMeImagePickerDelegate?
  
    // Declare IBActions for the buttons on the screen
    @IBAction func shareButtonWasPressed(_ sender: Any) {
        
        // generate the memed image
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities:nil)
        present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {(type,completed,item,error) in
            
            if completed {
                self.save(memedImage: memedImage)
            }
        
        }
    }
    
    // Return the view to its original state if a user taps the cancel button and take the user back to the initial view controller
    @IBAction func cancelButtonPressed(_ sender: Any) {
        clearView()
        
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
        
    }
    
    // IBAction that will present the camera to the user to allow them to take a picture they want to meme
    @IBAction func cameraButtonPressed(_ sender: Any) {
    
        // bring up the phones camera so the user can take a picture
        pick(sourceType: .camera)
    }
    
    // IBAction that will present the camera album to the user to allow them to pick the picture they want to meme
    @IBAction func albumButtonPressed(_ sender: Any) {
       
        // bring up the camera roll so the user can pick a picture
        pick(sourceType: .photoLibrary)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign imagePickerDelegate
        imagePickerDelegate = MemeMeImagePickerDelegate(imageView: imageView)
        
        // call the configureUI method
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check whether the device has a camera, if not, disable the camera button
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = false
        }
        
        // subscribe to the keyboard notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // unsubscribe to the keyboard notifications
        unsubscribeToKeyboardNotifications()
    }
    
    
    // custom method to configure any UI elements in the view
    func configureUI() {
        
        // set a list of properties for the text atributes
        let memeTextAtrributes: [String: Any] = [NSStrokeColorAttributeName: UIColor.black,
                                              NSForegroundColorAttributeName: UIColor.white,
                                              NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                                              NSStrokeWidthAttributeName: -4]
        
        // set the top and bottom text field attributes to the dictionary of attributes we set above
        prepareTextField(textField: topTextField, attributes: memeTextAtrributes)
        prepareTextField(textField: bottomTextField, attributes: memeTextAtrributes)
        
        // set the image viwes content mode
        imageView.contentMode = .scaleAspectFit
    }
    
    // custom method to clear the view if the cancel button is pressed
    func clearView() {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        configureUI()
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
    
    func keyboardWillShow(notification: Notification) {
        
        // adjust the view for the keyboard so nothing gets cut off for the bottom text field only
        
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
        
    }
    
    func keyboardWillHide(notification: Notification) {
        
        // adjust the view back to its original position
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return (keyboardSize.cgRectValue.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Methods to configure the UITextFields
    
    func prepareTextField(textField: UITextField, attributes: [String: Any]) {
        textField.defaultTextAttributes = attributes
        textField.textAlignment = .center
    }
    
    // MARK: - UIImagePickerController method to pick the desired image picker
    
    func pick(sourceType: UIImagePickerControllerSourceType) {
        
        // bring up the phones camera so the user can take a picture
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = imagePickerDelegate
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)

    }
    
    // MARK: - Method to generate/save the memed image
    
    // Method to generate the memed image
    func generateMemedImage() -> UIImage {
        
        // hide the toolbar and nav bar first so that way we can capture the screen with the image and text without having the toolbar and nav bar in the memed image
        toolbar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        // Render the view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext() 
        
        // no re-show the toolbar and nav bar
        toolbar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        // create the meme 
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        print(appDelegate.memes.count)
        
        navigationController?.popToRootViewController(animated: true)
    }
    
}



// MARK: - Custom Delegate class for UIImagePickerDelegate that way we keep the VC doing as little as possible (Do one thing, do it well. (https://vimeo.com/204897590)

class MemeMeImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Delcare properties needed to save/create a Memed Image
    var imageView: UIImageView

    // Custom Initializer 
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // grab the image that was selected
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
