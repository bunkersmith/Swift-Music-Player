//
//  DatabaseInterface.swift
//  Swift Music Player
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseInterface: NSObject {
    fileprivate var context:NSManagedObjectContext!
    
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    init(concurrencyType: NSManagedObjectContextConcurrencyType) {
        super.init()
        let databaseManager = DatabaseManager.instance
        if concurrencyType == .mainQueueConcurrencyType {
            context = databaseManager.returnMainManagedObjectContext()
        }
        else {
            context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = databaseManager.returnPersistentStoreCoordinator()
        }
        
        //Logger.writeToLogFile("context = \(context)")
    }
    
    func performInBackground(_ block: @escaping () -> Void) {
        context.perform(block)
    }
    
    func newManagedObjectOfType(_ managedObjectClassName:String) -> NSManagedObject? {
        if let entityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: managedObjectClassName, in: context) {
            return NSManagedObject(entity: entityDescription, insertInto: context)
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
    
    func entitiesOfType(_ entityTypeName:String, predicate:NSPredicate?) -> [AnyObject] {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            Logger.writeToLogFile("entitiesOfType for entity name \(entityTypeName) error: \(error)")
        }
        Logger.writeToLogFile("entitysOfType returning empty array for entity name \(entityTypeName)")
        return [AnyObject]()
    }
    
    func entitiesOfType(_ entityTypeName:String, fetchRequestChangeBlock:((_ inputFetchRequest:NSFetchRequest<NSManagedObject>) -> NSFetchRequest<NSManagedObject>)?) -> [AnyObject] {
        var fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if let localFetchRequestChangeBlock = fetchRequestChangeBlock {
            fetchRequest = localFetchRequestChangeBlock(fetchRequest as! NSFetchRequest<NSManagedObject>) as! NSFetchRequest<NSFetchRequestResult>
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            Logger.writeToLogFile("entitiesOfType for entity name \(entityTypeName) error: \(error)")
        }
        Logger.writeToLogFile("entitysOfType returning empty array for entity name \(entityTypeName)")
        return [AnyObject]()
    }
    
    func countOfEntitiesOfType(_ entityTypeName:String, predicate:NSPredicate?) -> Int {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        var result:Int = 0
        
        do {
            result = try context.count(for: fetchRequest)
        } catch let error as NSError {
            Logger.writeToLogFile("countOfEntitiesOfType for entity name \(entityTypeName) error: \(error)")
        }
        
        return result
    }
    
    func createFetchedResultsController(_ entityName:String, sortKey:String, secondarySortKey:String?, sectionNameKeyPath:String?, predicate:NSPredicate?) -> NSFetchedResultsController<NSFetchRequestResult> {
/*
        Logger.logDetails(msg: "Entered")
        Logger.writeToLogFile("entityName: \(entityName)")
        Logger.writeToLogFile("sortKey: \(sortKey)")
        Logger.writeToLogFile("secondarySortKey: \(secondarySortKey)")
        Logger.writeToLogFile("sectionNameKeyPath: \(sectionNameKeyPath)")
        Logger.writeToLogFile("predicate: \(predicate)")
*/
        
        //:NSFetchedResultsController<NSManagedObject>
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)

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
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            Logger.writeToLogFile("Error initializing fetchedResultsController for \(entityName): \(error)")
        }
        
        return fetchedResultsController
    }
    
    func deleteObject(_ coreDataObject:AnyObject)
    {
        if let managedObject = coreDataObject as? NSManagedObject {
            context.delete(managedObject)
            saveContext()
        }
        else {
            Logger.writeToLogFile("Error casting object to NSManagedObject in deleteObject")
        }
    }
    
    func deleteAllObjectsWithEntityName(_ entityName: String)
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in:context)
        fetchRequest.entity = entity
    
        do {
            if let items:[NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                for managedObject:NSManagedObject in items {
                    context.delete(managedObject)
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
