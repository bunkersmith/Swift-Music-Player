//
//  Genre.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Genre: NSManagedObject {

    @NSManaged var artists: NSSet
    @NSManaged var summary: GenreSummary

    func addArtistsObject(_ value:Artist)
    {
        self.willChangeValue(forKey: "artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.add(value)
        self.artists = tempSet
        self.didChangeValue(forKey: "artists")
    }
    
    func addArtistsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.addObjects(from: values as [AnyObject])
        self.artists = tempSet
        self.didChangeValue(forKey: "artists")
    }
    
    func removeArtistsObject(_ value:Artist)
    {
        self.willChangeValue(forKey: "artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.remove(value)
        self.artists = tempSet
        self.didChangeValue(forKey: "artists")
    }
    
    func removeArtistsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "artists")
        let tempSet:NSMutableSet = NSMutableSet(set:self.artists)
        tempSet.minus(NSSet(array:values as [AnyObject]) as Set<NSObject>)
        self.artists = tempSet
        self.didChangeValue(forKey: "artists")
    }
    
    override var description: String {
        var returnValue = "***** GENRE *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nsongs:"
        for (_, object) in artists.enumerated() {
            let artist = object as! Artist
            returnValue = returnValue + "\n\(artist.summary.name)"
        }
        return returnValue
    }
}
