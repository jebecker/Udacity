//
//  Student.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/15/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation


struct Student {
    
    // MARK: - Properties
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let location: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    // MARK: - custom initializer
    init?(dictionary: [String:AnyObject]) {
        
        guard let objectId = dictionary[Constants.JSONResponseKeys.ObjectId] as? String,
            let firstName = dictionary[Constants.JSONResponseKeys.FirstName] as? String,
            let lastName = dictionary[Constants.JSONResponseKeys.LastName] as? String,
            let location = dictionary[Constants.JSONResponseKeys.MapString] as? String,
            let mediaURL = dictionary[Constants.JSONResponseKeys.MediaURL] as? String,
            let latitude = dictionary[Constants.JSONResponseKeys.Latitude] as? Double,
            let longitude = dictionary[Constants.JSONResponseKeys.Longitude] as? Double
            else {
                print("COULD NOT PARSE STUDENT DICATIONARY PASSED IN")
                return nil
            }
        
        let uniqueKey = dictionary[Constants.JSONResponseKeys.UniqueKey] as? String ?? "jb618s@att.com"
        
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func studentsFromResults(results: [[String:AnyObject]]) -> [Student] {
        
        var students = [Student]()
        // iterate through the array of dictionaries since each student is its own dictionary
        for result in results {
            if let student = Student(dictionary: result) {
                students.append(student)
            }
        }
        return students
    }
}
