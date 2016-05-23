//
//  DatabaseInterface.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseInterface: NSObject {
    private var context:NSManagedObjectContext!
    
    init(forMainThread: Bool) {
        super.init()
        let databaseManager:DatabaseManager = DatabaseManager.instance
        if forMainThread {
            context = databaseManager.returnMainManagedObjectContext()
        }
        else {
            context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            context.persistentStoreCoordinator = databaseManager.returnPersistentStoreCoordinator()
        }
        
        //NSLog("context = \(context)")
    }
    
    func performInBackground(block: () -> Void) {
        context.performBlock(block)
    }
    
    func newManagedObjectOfType(managedObjectClassName:String) -> NSManagedObject? {
        if let entityDescription:NSEntityDescription = NSEntityDescription.entityForName(managedObjectClassName, inManagedObjectContext: context) {
            return NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: context)
        }
        Logger.writeToLogFile("Could not get entity description for managed object class \(managedObjectClassName)")
        return nil
    }
    
    func saveContext() {
        if context != nil {
            do {
                try context.save()
            } catch let error as NSError {
                Logger.writeToLogFile("Error saving context in DatabaseInterface.saveContext(): \(error)")
            }
        }
        else {
            Logger.writeToLogFile("No context in DatabaseInterface.saveContext()")
        }
    }
    
    func entitiesOfType(entityTypeName:String, predicate:NSPredicate?) -> [AnyObject] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            return result
        } catch let error as NSError {
            Logger.writeToLogFile("entitiesOfType for entity name \(entityTypeName) error: \(error)")
        }
        Logger.writeToLogFile("entitysOfType returning empty array for entity name \(entityTypeName)")
        return [AnyObject]()
    }
    
    func entitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((inputFetchRequest:NSFetchRequest) -> NSFetchRequest)?) -> [AnyObject] {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if let localFetchRequestChangeBlock = fetchRequestChangeBlock {
            fetchRequest = localFetchRequestChangeBlock(inputFetchRequest: fetchRequest)
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            return result
        } catch let error as NSError {
            Logger.writeToLogFile("entitiesOfType for entity name \(entityTypeName) error: \(error)")
        }
        Logger.writeToLogFile("entitysOfType returning empty array for entity name \(entityTypeName)")
        return [AnyObject]()
    }
    
    func countOfEntitiesOfType(entityTypeName:String, predicate:NSPredicate?) -> Int {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        var error:NSError?
        let result:Int = context.countForFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            Logger.writeToLogFile("countOfEntitiesOfType for entity name \(entityTypeName) error: \(error)")
        }

        return result
    }
    
    func createFetchedResultsController(entityName:String, sortKey:String, secondarySortKey:String?, sectionNameKeyPath:String?, predicate:NSPredicate?) -> NSFetchedResultsController {
        var fetchedResultsController:NSFetchedResultsController
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)

        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        var sortDescriptors = [sortDescriptor]
        if let localSecondarySortKey = secondarySortKey {
            let secondarySortDescriptor:NSSortDescriptor = NSSortDescriptor(key: localSecondarySortKey, ascending: true)
            sortDescriptors = [sortDescriptor, secondarySortDescriptor]
        }
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.fetchBatchSize = 30
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            Logger.writeToLogFile("Error initializing fetchedResultsController for \(entityName): \(error)")
        }
        
        return fetchedResultsController
    }
    
    func deleteObject(coreDataObject:AnyObject)
    {
        if let managedObject = coreDataObject as? NSManagedObject {
            context.deleteObject(managedObject)
            saveContext()
        }
        else {
            Logger.writeToLogFile("Error casting object to NSManagedObject in deleteObject")
        }
    }
    
    func deleteAllObjectsWithEntityName(entityName: String)
    {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
        fetchRequest.entity = entity
    
        do {
            if let items:[NSManagedObject] = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                for managedObject:NSManagedObject in items {
                    context.deleteObject(managedObject)
                }
                saveContext()
            }
            else {
                Logger.writeToLogFile("Could not downcast entities named \(entityName) in deleteAllObjectsWithEntityName")
            }
        }
        catch let error as NSError {
            Logger.writeToLogFile("Error fetching (before deleting) all entities named \(entityName): \(error)")
        }
    }
}