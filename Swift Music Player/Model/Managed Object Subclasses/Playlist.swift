//
//  Playlist.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Playlist: NSManagedObject {

    @NSManaged var songSummaries: NSOrderedSet
    @NSManaged var summary: PlaylistSummary
    
    func addSongSummariesObject(_ value:SongSummary)
    {
        self.willChangeValue(forKey: "songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.add(value)
        self.songSummaries = tempSet
        self.didChangeValue(forKey: "songSummaries")
    }
    
    func addSongSummariesObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.addObjects(from: values as [AnyObject])
        self.songSummaries = tempSet
        self.didChangeValue(forKey: "songSummaries")
    }
    
    func removeSongSummariesObject(_ value:SongSummary)
    {
        self.willChangeValue(forKey: "songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.remove(value)
        self.songSummaries = tempSet
        self.didChangeValue(forKey: "songSummaries")
    }
    
    func removeSongSummariesObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.removeObjects(in: values as [AnyObject])
        self.songSummaries = tempSet
        self.didChangeValue(forKey: "songSummaries")
    }
    
    override var description: String {
        var returnValue = "***** PLAYLIST *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nsongSummaries:"
        for (_, object) in songSummaries.enumerated() {
            let songSummary = object as! SongSummary
            returnValue = returnValue + "\n\(songSummary.title) by \(songSummary.artistName)"
        }
        
        return returnValue
    }

}
