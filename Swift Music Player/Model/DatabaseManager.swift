//
//  DatabaseManager.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager : NSObject {
    var databaseBuildInProgress:Bool = false
    
    class var instance: DatabaseManager {
    struct Singleton {
        static let instance = DatabaseManager()
        }
        return Singleton.instance
    }
    
    func returnPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        return storeCoordinator
    }
    
    func returnMainManagedObjectContext() -> NSManagedObjectContext {
        return mainContext
    }
    
    lazy private var storeURL:NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent("MusicByCarlSwift.sqlite")
    }()
    
    lazy private var modelURL:NSURL = {
        if var returnValue = NSBundle.mainBundle().URLForResource("MusicByCarlSwift", withExtension: "momd") {
            return returnValue
        }
        else {
            Logger.writeToLogFile("Could not retrieve model URL")
            return NSURL()
        }
    }()

    lazy private var model:NSManagedObjectModel = {
        if var returnValue = NSManagedObjectModel(contentsOfURL: self.modelURL) {
            return returnValue
        }
        else {
            Logger.writeToLogFile("Could not retrieve managed object model")
            return NSManagedObjectModel()
        }
    }()

    lazy private var storeCoordinator:NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel:self.model)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        var error: NSError?
        
        do {
            try storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                        configuration: nil, URL: self.storeURL, options: options)
        } catch var error1 as NSError {
            error = error1
                Logger.writeToLogFile("Error adding persistent store to store coordinator: \(error)")
                abort()
        } catch {
            fatalError()
        }
        
        return storeCoordinator
    }()
    
    lazy private var mainContext:NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.storeCoordinator
        return mainContext
    }()
    
    lazy private var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
}
