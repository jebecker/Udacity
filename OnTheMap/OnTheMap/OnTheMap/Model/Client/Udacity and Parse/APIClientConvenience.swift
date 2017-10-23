//
//  APIClientConvenience.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/15/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension APIClient {
    
    // method to call the udacity session api method
    func establishUdacitySession(username: String, password: String, completionHandlerForUdacitySession: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        // create the jsonBody for the request and define the method to be used
        let jsonBody = "{\"\(Constants.JSONBodyKeys.Udacity)\": {\"\(Constants.JSONBodyKeys.Username)\": \"\(username)\", \"\(Constants.JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        let _ = taskForUdacityPOSTMethod(Constants.Methods.UdacitySession, jsonBody: jsonBody) { (results, error) in
            
            // send the desired values to the completion handler
            guard (error == nil) else {
                completionHandlerForUdacitySession(nil, error)
                return
            }
            
            guard let results = results,
                let result = results[Constants.JSONResponseKeys.Account] as? [String:AnyObject],
                let userId = result[Constants.JSONResponseKeys.AccountKey] as? String
                else {
                    completionHandlerForUdacitySession(nil, NSError(domain: "establishUdacitySession", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get the result from the UDACITY SESSION POST method"]))
                    return
                }
            
            // we know we had a successful request if we get here
            completionHandlerForUdacitySession(userId, nil)
        }
    }
    
    // method to call the student location API method
    func getStudentInformation(_ completionHandlerForStudentInformation: @escaping (_ result: Student?, _ error: NSError?) -> Void) {
        
        let _ = taskForGETMethod(Constants.Methods.ParseStudentLocation) { (results, error) in
            
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForStudentInformation(nil, error)
                return
            }
            
            guard let results = results?[Constants.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                completionHandlerForStudentInformation(nil, NSError(domain: "getStudentInformation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get the result from the PARSE Student Location API Method"]))
                return
            }
            
            // we know we have a successful reponse if we get here
            let students = Student.studentsFromResults(results: results)
            completionHandlerForStudentInformation(students, nil)
        }
    }
    
    // MARK: - GET Udacity User Information
    func getUdacityUserInformation(userId: String, completionHandlerForGETUdacityUserInformation: @escaping (_ result: User?, _ error: NSError? ) -> Void) {
        // create the method with the passed in userId
        if let method = substituteKeyInMethod(Constants.Methods.UdacityPublicUserData, key: "user_id", value: userId) {
            
            let _ = taskForUdacityGETMethod(method) { (results, error) in
                
                // check to see if there was an error returned
                guard error == nil else {
                    completionHandlerForGETUdacityUserInformation(nil, error)
                    return
                }
                
                guard let results = results,
                    let userInfo = results["user"] as? [String:AnyObject],
                    let firstName = userInfo[Constants.JSONResponseKeys.UdacityFirstName] as? String,
                    let lastName = userInfo[Constants.JSONResponseKeys.UdacityLastName] as? String
                    else {
                        completionHandlerForGETUdacityUserInformation(nil, NSError(domain: "getUdacityUserInformation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get the result from the UDACITY User API Method"]))
                        return
                }
                
                // create a User object to be passed back via the completionHandler
                let user = User(firstName: firstName, lastName: lastName, userId: userId)
                completionHandlerForGETUdacityUserInformation(user, nil)
            }
            
        }
        
    }
    
    // MARK: - POST Student Location Method
    func postStudentLocation(userId: String, firstName: String, lastName: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, location: String, completionHandlerForPOSTStudentLocation: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        // create the jsonBody for the request and define the method to be used
        let jsonBody = "{\"\(Constants.JSONBodyKeys.UniqueKey)\": \"\(userId)\", \"\(Constants.JSONBodyKeys.FirstName)\": \"\(firstName)\", \"\(Constants.JSONBodyKeys.LastName)\": \"\(lastName)\",\"\(Constants.JSONBodyKeys.MapString)\": \"\(location)\", \"\(Constants.JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(Constants.JSONBodyKeys.Latitude)\": \(latitude), \"\(Constants.JSONBodyKeys.Longitude)\": \(longitude)}"
        
        let _ = taskForPOSTMethod(Constants.Methods.ParseStudentLocation, jsonBody: jsonBody) { (result, error) in
            // check to see if there was an error returned
            guard error == nil else {
                completionHandlerForPOSTStudentLocation(nil, error)
                return
            }
        
            // if there was no error we know we had a successful response
            completionHandlerForPOSTStudentLocation(1, nil)
        }
    }
    
    // MARK: - LOGOUT
    func logout(_ completionHandlerForLogout: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        // start the request
        let _ = taskForUdacityDELETESession(Constants.Methods.UdacitySession) { (results, error) in
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForLogout(nil, error)
                return
            }
            
            // if no error, then we know we logged out fine
            completionHandlerForLogout(1, nil)
        }
    }
    
}
