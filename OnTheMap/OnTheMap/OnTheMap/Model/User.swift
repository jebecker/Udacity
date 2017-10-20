//
//  User.swift
//  OnTheMap
//
//  Created by Jayme Becker on 10/16/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation

// Custom USER Struct for the signed in user
struct User {
    
    // MARK: - Properties
    let firstName: String
    let lastName: String
    let userId: String
    
    init(firstName: String, lastName: String, userId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userId = userId
    }
    
}
