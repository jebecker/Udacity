//
//  CoreDataConvenience.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/19/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataConvenience {
   
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            executeSearch()
        }
    }
    
    func executeSearch() {
        if let fetchedResultsController = fetchedResultsController {
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
            }
        }
    }
}
