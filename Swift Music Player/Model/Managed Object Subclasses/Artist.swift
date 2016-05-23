//
//  Artist.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Artist: NSManagedObject {

    @NSManaged var albums: NSOrderedSet
    @NSManaged var genres: NSSet
    @NSManaged var summary: ArtistSummary
    
    func addAlbumsObject(value:Album)
    {
        self.willChangeValueForKey("albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.addObject(value)
        self.albums = tempSet
        self.didChangeValueForKey("albums")
    }
    
    func addAlbumsObjects(values:NSArray)
    {
        self.willChangeValueForKey("albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.addObjectsFromArray(values as [AnyObject])
        self.albums = tempSet
        self.didChangeValueForKey("albums")
    }
    
    func removeAlbumsObject(value:Album)
    {
        self.willChangeValueForKey("albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.removeObject(value)
        self.albums = tempSet
        self.didChangeValueForKey("albums")
    }
    
    func removeAlbumsObjects(values:NSArray)
    {
        self.willChangeValueForKey("albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        let valuesSet:NSSet = NSSet(array: values as [AnyObject])
        tempSet.minusSet(valuesSet as Set<NSObject>)
        self.albums = tempSet
        self.didChangeValueForKey("albums")
    }
    
    override var description: String {
        var returnValue = "***** ARTIST *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        
        returnValue = returnValue + "\nalbums:"
        for (_, object) in albums.enumerate() {
            returnValue = returnValue + "\n\(object as! Album)"
        }
        
        returnValue = returnValue + "\ngenres:"
        for (_, object) in genres.enumerate() {
            returnValue = returnValue + "\n\(object as! Genre)"
        }
        
        return returnValue
    }
}
