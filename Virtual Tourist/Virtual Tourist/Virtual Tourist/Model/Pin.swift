//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/2/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    
    // MARK - Initializer
    
    convenience init(latitdue: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // grab the entity from CoreData and set its properties
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.longitude = longitude
            self.latitude = latitdue
        } else {
            fatalError("Unable to find entity 'Pin'!")
        }
        
    }
    
}
