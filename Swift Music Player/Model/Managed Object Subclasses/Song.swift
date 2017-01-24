//
//  Song.swift
//  Swift Music Player
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
    @NSManaged var assetURL: Data
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
        if let descAssetURL = NSKeyedUnarchiver.unarchiveObject(with: assetURL) as? URL {
            returnValue = returnValue + "\nassetURL: " + descAssetURL.absoluteString
        }
        returnValue = returnValue + "\nduration: \(DateTimeUtilities.durationToMinutesAndSecondsString(duration)) (\(duration))"
        returnValue = returnValue + "\ngenreName: " + genreName
        returnValue = returnValue + "\nalbumPersistentID: \(albumPersistentID)"
        returnValue = returnValue + "\ntrackNumber: \(trackNumber)"
        returnValue = returnValue + "\ninPlaylists:"
        if album != nil {
            returnValue = returnValue + "\nalbumName: " + album!.summary.title
        }
        return returnValue
    }
    
    func albumArtwork() -> MPMediaItemArtwork? {
        var returnValue:MPMediaItemArtwork? = nil
        
        if album != nil {
            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            returnValue = album?.albumArtwork(databaseInterface)
        }
        
        return returnValue
    }
    
    func updateLastPlayedTime(_ lastPlayedTimeValue: TimeInterval, databaseInterface: DatabaseInterface) {
        summary.lastPlayedTime = lastPlayedTimeValue
        databaseInterface.saveContext()
        writeSongToPlayedSongsFile()
    }
    
    func writeSongToICloudPlayedSongsFile(songPlayString: String) {

        let icDocWrapper = ICloudDocWrapper(filename: FileUtilities.iCloudPlayedSongsFileName())
        
        icDocWrapper.appendTextToDoc(text: songPlayString) { (docResult) in
            Logger.logDetails(msg: "docResult = \(docResult)")
        }
    }
    
    func writeSongToPlayedSongsFile() {
        var songPlayString = "title:\t\(summary.title)\n"
        songPlayString += "artist:\t\(summary.artistName)\n"
        songPlayString += "album:\t\(album!.summary.title)\n"
        songPlayString += "persistentKey:\t\(summary.persistentKey)\n"
        songPlayString += "lastPlayedTime:\t\(summary.lastPlayedTime)\t\(DateTimeUtilities.timeIntervalToString(summary.lastPlayedTime))\n"
        
        let fileurl =  URL(fileURLWithPath: FileUtilities.playedSongsFilePath(), isDirectory: false)
  
        let data = songPlayString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        if FileManager.default.fileExists(atPath: fileurl.path) {
            var err:NSError?
            do {
                let fileHandle = try FileHandle(forWritingTo: fileurl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch let error as NSError {
                err = error
                Logger.writeToLogFile("Can't open played songs file \(err)")
            }
        }
        else {
            var err:NSError?
            do {
                try data.write(to: fileurl, options: .atomic)
            } catch let error as NSError {
                err = error
                Logger.writeToLogFile("Can't write to played songs file \(err)")
            }
        }

        // let myText = try! String(contentsOf: fileurl, encoding: String.Encoding.utf8)
        
        // Change the following line from: writeSongToICloudPlayedSongsFile(songPlayString: songPlayString)
        // to writeSongToICloudPlayedSongsFile(songPlayString: myText)
        // and the entire local played songs file will be written to the iCloud played songs file
        
        writeSongToICloudPlayedSongsFile(songPlayString: songPlayString)
    }
}
