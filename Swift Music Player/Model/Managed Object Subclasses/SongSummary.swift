//
//  SongSummary.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class SongSummary: NSManagedObject {

    @NSManaged var artistName: String
    @NSManaged var indexCharacter: String
    @NSManaged var lastPlayedTime: TimeInterval
    @NSManaged var persistentID: UInt64
    @NSManaged var persistentKey: Int64
    @NSManaged var searchKey: String
    @NSManaged var strippedTitle: String
    @NSManaged var title: String
    @NSManaged var forSong: Song
    @NSManaged var inPlaylists: NSSet
    
    override var description: String {
        var returnValue = "***** SONG SUMMARY *****"
        returnValue = returnValue + "\nartistName: " + artistName
        returnValue = returnValue + "\nindexCharacter: *" + indexCharacter + "*"
        returnValue = returnValue + "\nstrippedTitle: " + strippedTitle
        returnValue = returnValue + "\ntitle: " + title
        returnValue = returnValue + "\nsearchKey: \(searchKey)"
        returnValue = returnValue + "\npersistentID: \(persistentID)"
        returnValue = returnValue + "\npersistentKey: \(persistentKey)"
        returnValue = returnValue + "\nlastPlayedTime: \(DateTimeUtilities.timeIntervalToString(lastPlayedTime))"
        for (_, object) in inPlaylists.enumerated() {
            let playlist = object as! Playlist
            returnValue = returnValue + "\n" + playlist.summary.title
        }
        return returnValue
    }
}
