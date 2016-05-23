//
//  Playlist.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Playlist: NSManagedObject {

    @NSManaged var songSummaries: NSOrderedSet
    @NSManaged var summary: PlaylistSummary
    
    func addSongSummariesObject(value:SongSummary)
    {
        self.willChangeValueForKey("songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.addObject(value)
        self.songSummaries = tempSet
        self.didChangeValueForKey("songSummaries")
    }
    
    func addSongSummariesObjects(values:NSArray)
    {
        self.willChangeValueForKey("songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.addObjectsFromArray(values as [AnyObject])
        self.songSummaries = tempSet
        self.didChangeValueForKey("songSummaries")
    }
    
    func removeSongSummariesObject(value:SongSummary)
    {
        self.willChangeValueForKey("songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.removeObject(value)
        self.songSummaries = tempSet
        self.didChangeValueForKey("songSummaries")
    }
    
    func removeSongSummariesObjects(values:NSArray)
    {
        self.willChangeValueForKey("songSummaries")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songSummaries)
        tempSet.removeObjectsInArray(values as [AnyObject])
        self.songSummaries = tempSet
        self.didChangeValueForKey("songSummaries")
    }
    
    override var description: String {
        var returnValue = "***** PLAYLIST *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nsongSummaries:"
        for (_, object) in songSummaries.enumerate() {
            let songSummary = object as! SongSummary
            returnValue = returnValue + "\n\(songSummary.title) by \(songSummary.artistName)"
        }
        
        return returnValue
    }

}
