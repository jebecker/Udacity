//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Jayme Becker on 12/2/17.
//  Copyright © 2017 Jayme Becker. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    // MARK: Properties
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let databaseURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    // MARK - Initializers
    
    init?(modelName: String) {
        
        // Assume the model is the main bundle
        // it should be :P
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle!")
            return nil
        }
        self.modelURL = modelURL
        
        // try and create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = persistingContext
        
        // create a background context which is a child of the main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = mainContext
        
        // Add a SQLite store located in the documents folder
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder!")
            return nil
        }
        
        self.databaseURL = documentURL.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(databaseURL)")
        }
        
    }
    
    // MARK: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
    
}

// MARK: - CoreDataStack (Removing Data)

internal extension CoreDataStack {
    
    func dropAllData() throws {
        // delete all the objects in the DB. This won't delete the files, it will just leave empty tables
        try coordinator.destroyPersistentStore(at: databaseURL, ofType: NSSQLiteStoreType, options: nil)
    }
}

// MARK: - CoreDataStack (Batch processing in the background)

extension CoreDataStack {
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform {
            batch(self.backgroundContext)
            
            // save it to the parent context, so normal saving can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {
    
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        mainContext.performAndWait {
            
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                } catch {
                    fatalError("Error while saving mainContext: \(error)")
                }
                
                // no we save in the background
                self.persistingContext.perform {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persistingContext: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            do {
                try self.mainContext.save()
                print("Autosaving")
            } catch {
                print("Error while autosaving!!")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
