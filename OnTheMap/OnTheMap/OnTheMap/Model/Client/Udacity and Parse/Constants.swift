//
//  Constants.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/14/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation

struct Constants {
    
    static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    static let UdacityURL = "https://www.udacity.com/api"
    static let ParseURL = "https://parse.udacity.com/parse/classes"
    
    struct Methods {
        static let UdacitySession = "/session"
        static let UdacityPublicUserData = "/users/{user_id}"
        static let ParseStudentLocation = "/StudentLocation"
        static let ParsePutStudentLocation = "/StudentLocation/{objectId}"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let UpdatedAt = "updatedAt"
    }
    
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let UdacityFirstName = "first_name"
        static let UdacityLastName = "last_name"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let User = "user"
        static let Account = "account"
        static let AccountKey = "key"
        static let Registered = "registered"
        static let Session = "session"
        static let SessionId = "id"
        static let Expiration = "expiration"
        static let Results = "results"
        
    }
    
}
