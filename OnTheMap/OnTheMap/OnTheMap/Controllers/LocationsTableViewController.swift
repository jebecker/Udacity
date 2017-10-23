//
//  LocationsTableViewController.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/15/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {

    // MARK: - Properties
    var students = Student()
    
    @IBAction func addPinButtonWasPressed(_ sender: UIBarButtonItem) {
        let informationPostingNavigationController = storyboard?.instantiateViewController(withIdentifier: "informationPostingNavigationController") as! UINavigationController
        present(informationPostingNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonWasPressed(_ sender: UIBarButtonItem) {
        configureView()
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: UIBarButtonItem) {
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
        
        configureView()
    }
    
    // method to configure the table view
    func configureView() {
        
        APIClient.sharedInstance().getStudentInformation() { (result, error) in
            guard let result = result else {
                self.displayAlert(message: "Sorry, but we could not get the student information from the Udacity server at this time. Please try again!")
                return
            }
            
            self.students = result
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.array.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // grab the student from the array of students
        let student = students.array[indexPath.row]
        
        let studentInformationCell = tableView.dequeueReusableCell(withIdentifier: "studentInformationCell") as! StudentInformationTableViewCell
        
        // configure the cell
        studentInformationCell.nameLabel.text = "\(student.firstName) \(student.lastName)"
        studentInformationCell.mediaURLLabel.text = "\(student.mediaURL)"
        
        return studentInformationCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // grab the specific rows student information
        let student = students.array[indexPath.row]
        
        // open the mediaURL of the student in SAFARI
        let app = UIApplication.shared
        app.open(URL(string: student.mediaURL)!, options: [:], completionHandler: nil)
    }
}

class StudentInformationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
}
