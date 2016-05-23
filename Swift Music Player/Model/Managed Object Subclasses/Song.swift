//
//  Song.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

class Song: NSManagedObject {

    @NSManaged var trackNumber: UInt64
    @NSManaged var genreName: String
    @NSManaged var duration: Double
    @NSManaged var assetURL: NSData
    @NSManaged var albumTitle: String
    @NSManaged var albumPersistentID: UInt64
    @NSManaged var albumArtistName: String
    @NSManaged var album: Album?
    @NSManaged var summary: SongSummary
    
    override var description: String {
        var returnValue = "***** SONG *****"
        returnValue = returnValue + "\nsummary: \(summary)"
        returnValue = returnValue + "\nalbumArtistName: " + albumArtistName
        returnValue = returnValue + "\nalbumTitle: " + albumTitle
        if let descAssetURL = NSKeyedUnarchiver.unarchiveObjectWithData(assetURL) as? NSURL {
            returnValue = returnValue + "\nassetURL: " + descAssetURL.absoluteString
        }
        returnValue = returnValue + "\nduration: \(DateTimeUtilities.durationToMinutesAndSecondsString(duration)) (\(duration))" // was %.0f
        returnValue = returnValue + "\ngenreName: " + genreName
        returnValue = returnValue + "\nalbumPersistentID: \(albumPersistentID)" // was %llu
        returnValue = returnValue + "\ntrackNumber: \(trackNumber)" // was %d
        returnValue = returnValue + "\ninPlaylists:"
        if album != nil {
            returnValue = returnValue + "\nalbumName: " + album!.summary.title
        }
        return returnValue
    }
    
    func albumArtwork() -> MPMediaItemArtwork? {
        var returnValue:MPMediaItemArtwork? = nil
        
        if album != nil {
            returnValue = album?.albumArtwork(DatabaseInterface(forMainThread: true))
        }
        
        return returnValue
    }
    
    func updateLastPlayedTime(lastPlayedTimeValue: NSTimeInterval, databaseInterface: DatabaseInterface) {
        summary.lastPlayedTime = lastPlayedTimeValue
        databaseInterface.saveContext()
        writeSongToPlayedSongsFile()
    }
    
    func writeSongToPlayedSongsFile() {
        let fileurl =  NSURL(fileURLWithPath: FileUtilities.playedSongsFilePath(), isDirectory: false)
        var songPlayString = "title:\t\(summary.title)\n"
        songPlayString += "artist:\t\(summary.artistName)\n"
        songPlayString += "album:\t\(album!.summary.title)\n"
        songPlayString += "persistentKey:\t\(summary.persistentKey)\n"
        songPlayString += "lastPlayedTime:\t\(summary.lastPlayedTime)\t\(DateTimeUtilities.timeIntervalToString(summary.lastPlayedTime))\n"
        
        let data = songPlayString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) {
            var err:NSError?
            do {
                let fileHandle = try NSFileHandle(forWritingToURL: fileurl)
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data)
                fileHandle.closeFile()
            } catch let error as NSError {
                err = error
                NSLog("Can't open played songs file \(err)")
            }
        }
        else {
            var err:NSError?
            do {
                try data.writeToURL(fileurl, options: .DataWritingAtomic)
            } catch let error as NSError {
                err = error
                NSLog("Can't write to played songs file \(err)")
            }
        }
    }
}
