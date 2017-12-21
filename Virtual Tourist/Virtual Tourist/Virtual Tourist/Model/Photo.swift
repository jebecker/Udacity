//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/2/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {

    // MARK: - Initializer
    
    convenience init(title: String = "New Photo", imageData: NSData, context: NSManagedObjectContext) {
        
        // create the 'Photo' entity and set all properties
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.imageData = imageData
        } else {
            fatalError("Unable to find entity name 'Photo'!")
        }
        
    }
    
}
