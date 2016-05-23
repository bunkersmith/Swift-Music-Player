//
//  Album.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

class Album: NSManagedObject {

    @NSManaged var artistPersistentID: UInt64
    @NSManaged var duration: Double
    @NSManaged var internalID: Int16
    @NSManaged var isInstrumental: Bool
    @NSManaged var persistentKey: Int64
    @NSManaged var releaseYearString: String
    @NSManaged var artist: Artist?
    @NSManaged var songs: NSOrderedSet
    @NSManaged var summary: AlbumSummary

    
    func addSongsObject(value:Song)
    {
        self.willChangeValueForKey("songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.addObject(value)
        self.songs = tempSet
        self.didChangeValueForKey("songs")
    }
    
    func addSongsObjects(values:NSArray)
    {
        self.willChangeValueForKey("songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.addObjectsFromArray(values as [AnyObject])
        self.songs = tempSet
        self.didChangeValueForKey("songs")
    }
    
    func removeSongsObject(value:Song)
    {
        self.willChangeValueForKey("songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.removeObject(value)
        self.songs = tempSet
        self.didChangeValueForKey("songs")
    }
    
    func removeSongsObjects(values:NSArray)
    {
        self.willChangeValueForKey("songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.removeObjectsInArray(values as [AnyObject])
        self.songs = tempSet
        self.didChangeValueForKey("songs")
    }
    
    func albumArtwork(databaseInterface:DatabaseInterface) -> MPMediaItemArtwork? {
        var albumArtwork:MPMediaItemArtwork? = nil
        
        if songs.count > 0 {
            let firstAlbumTrackSong = songs.firstObject as! Song
            var firstAlbumTrackMediaItem:MPMediaItem
            
            let songQuery = MPMediaQuery.songsQuery()
            songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(unsignedLongLong: firstAlbumTrackSong.summary.persistentID), forProperty: MPMediaItemPropertyPersistentID))
            if let queriedSongs:Array<MPMediaItem>? = songQuery.items {
                if queriedSongs!.count == 1 {
                    firstAlbumTrackMediaItem = queriedSongs!.first!
                    albumArtwork = firstAlbumTrackMediaItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                }
            }
        }
        return albumArtwork
    }
    
    override var description: String {
        var returnValue = "***** ALBUM *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nduration: \(DateTimeUtilities.durationToMinutesAndSecondsString(duration)) (\(duration))" // was %.0f
        returnValue = returnValue + "\nisInstrumental: \(isInstrumental.boolValue)"
        returnValue = returnValue + "\nreleaseYearString: " + releaseYearString
        returnValue = returnValue + "\npersistentKey: \(persistentKey)" // was %llu
        returnValue = returnValue + "\ninternalID: \(internalID)"
        returnValue = returnValue + "\nartistPersistentID: \(artistPersistentID)" // was %llu
        if artist != nil {
            returnValue = returnValue + "\nartist: \(artist!.summary.name)"
        }
        returnValue = returnValue + "\nsongs:"
        for (_, object) in songs.enumerate() {
            let song = object as! Song
            if song.summary.artistName == song.albumArtistName {
                returnValue = returnValue + "\n\(song.summary.title)"
            }
            else {
                returnValue = returnValue + "\n\(song.summary.title) by \(song.summary.artistName)"
            }
        }
        return returnValue
    }
}
