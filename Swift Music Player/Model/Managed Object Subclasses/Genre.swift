//
//  Genre.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Genre: NSManagedObject {

    @NSManaged var artists: NSSet
    @NSManaged var summary: GenreSummary

    func addArtistsObject(value:Artist)
    {
        self.willChangeValueForKey("artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.addObject(value)
        self.artists = tempSet
        self.didChangeValueForKey("artists")
    }
    
    func addArtistsObjects(values:NSArray)
    {
        self.willChangeValueForKey("artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.addObjectsFromArray(values as [AnyObject])
        self.artists = tempSet
        self.didChangeValueForKey("artists")
    }
    
    func removeArtistsObject(value:Artist)
    {
        self.willChangeValueForKey("artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.removeObject(value)
        self.artists = tempSet
        self.didChangeValueForKey("artists")
    }
    
    func removeArtistsObjects(values:NSArray)
    {
        self.willChangeValueForKey("artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.minusSet(NSSet(array:values as [AnyObject]) as Set<NSObject>)
        self.artists = tempSet
        self.didChangeValueForKey("artists")
    }
    
    override var description: String {
        var returnValue = "***** GENRE *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nsongs:"
        for (_, object) in artists.enumerate() {
            let artist = object as! Artist
            returnValue = returnValue + "\n\(artist.summary.name)"
        }
        return returnValue
    }
}
