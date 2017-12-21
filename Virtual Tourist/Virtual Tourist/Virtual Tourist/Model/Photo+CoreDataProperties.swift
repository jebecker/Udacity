//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/2/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var title: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
