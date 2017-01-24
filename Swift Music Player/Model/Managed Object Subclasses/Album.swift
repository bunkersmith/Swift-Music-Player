//
//  Album.swift
//  Swift Music Player
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

    
    func addSongsObject(_ value:Song)
    {
        self.willChangeValue(forKey: "songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.add(value)
        self.songs = tempSet
        self.didChangeValue(forKey: "songs")
    }
    
    func addSongsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.addObjects(from: values as [AnyObject])
        self.songs = tempSet
        self.didChangeValue(forKey: "songs")
    }
    
    func removeSongsObject(_ value:Song)
    {
        self.willChangeValue(forKey: "songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.remove(value)
        self.songs = tempSet
        self.didChangeValue(forKey: "songs")
    }
    
    func removeSongsObjects(_ values:NSArray)
    {
        self.willChangeValue(forKey: "songs")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.songs)
        tempSet.removeObjects(in: values as [AnyObject])
        self.songs = tempSet
        self.didChangeValue(forKey: "songs")
    }
    
    func albumArtwork(_ databaseInterface:DatabaseInterface) -> MPMediaItemArtwork? {
        var albumArtwork:MPMediaItemArtwork? = nil
        
        if songs.count > 0 {
            let firstAlbumTrackSong = songs.firstObject as! Song
            var firstAlbumTrackMediaItem:MPMediaItem
            
            let songQuery = MPMediaQuery.songs()
            songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(value: firstAlbumTrackSong.summary.persistentID as UInt64), forProperty: MPMediaItemPropertyPersistentID))
            if let queriedSongs:Array<MPMediaItem> = songQuery.items {
                if queriedSongs.count == 1 {
                    firstAlbumTrackMediaItem = queriedSongs.first!
                    albumArtwork = firstAlbumTrackMediaItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                }
            }
        }
        return albumArtwork
    }
    
    override var description: String {
        var returnValue = "***** ALBUM *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nduration: \(DateTimeUtilities.durationToMinutesAndSecondsString(duration)) (\(duration))"
        returnValue = returnValue + "\nisInstrumental: \(isInstrumental)"
        returnValue = returnValue + "\nreleaseYearString: " + releaseYearString
        returnValue = returnValue + "\npersistentKey: \(persistentKey)"
        returnValue = returnValue + "\ninternalID: \(internalID)"
        returnValue = returnValue + "\nartistPersistentID: \(artistPersistentID)"
        if artist != nil {
            returnValue = returnValue + "\nartist: \(artist!.summary.name)"
        }
        returnValue = returnValue + "\nsongs:"
        for (_, object) in songs.enumerated() {
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
