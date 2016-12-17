//
//  Artist.swift
//  Swift Music Player
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
    
    func addAlbumsObject(_ value:Album)
    {
        self.willChangeValue(forKey: "albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.add(value)
        self.albums = tempSet
        self.didChangeValue(forKey: "albums")
    }
    
    func addAlbumsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.addObjects(from: values as [AnyObject])
        self.albums = tempSet
        self.didChangeValue(forKey: "albums")
    }
    
    func removeAlbumsObject(_ value:Album)
    {
        self.willChangeValue(forKey: "albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        tempSet.remove(value)
        self.albums = tempSet
        self.didChangeValue(forKey: "albums")
    }
    
    func removeAlbumsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "albums")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.albums)
        let valuesSet:NSSet = NSSet(array: values as [AnyObject])
        tempSet.minusSet(valuesSet as Set<NSObject>)
        self.albums = tempSet
        self.didChangeValue(forKey: "albums")
    }
    
    override var description: String {
        var returnValue = "***** ARTIST *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        
        returnValue = returnValue + "\nalbums:"
        for (_, object) in albums.enumerated() {
            returnValue = returnValue + "\n\(object as! Album)"
        }
        
        returnValue = returnValue + "\ngenres:"
        for (_, object) in genres.enumerated() {
            returnValue = returnValue + "\n\(object as! Genre)"
        }
        
        return returnValue
    }
}
