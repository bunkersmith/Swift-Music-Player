//
//  SongFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class SongFetcher {
    
    class func fetchSongBySongPersistentKey(_ persistentKey: Int64, databaseInterface:DatabaseInterface) -> Song? {
        let songObjects:Array<Song> = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format: "summary.persistentKey == %lld", persistentKey)) as! Array<Song>
        
        if songObjects.count == 1 {
            return songObjects.first
        }
        return nil
    }
    
    class func fetchSongByTitleArtistAndAlbum(_ title: String, artistName: String, albumTitle: String, databaseInterface: DatabaseInterface) -> Song? {
        let predicate = NSPredicate(format: "summary.title == %@ AND summary.artistName = %@ AND albumTitle = %@", title, artistName, albumTitle)
        
        let songObjects:Array<Song> = databaseInterface.entitiesOfType("Song", predicate: predicate) as! Array<Song>
        if songObjects.count == 1 {
            return songObjects.first
        }
        
        return nil
    }
    
    class func fetchSongSummaryWithPersistentID(_ persistentID: UInt64, databaseInterface: DatabaseInterface) -> SongSummary? {
        let songSummaries:Array<SongSummary> = databaseInterface.entitiesOfType("SongSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<SongSummary>
        if songSummaries.count == 1 {
            return songSummaries.first
        }
        
        return nil
    }
    
    class func fetchSongWithPersistentID(_ persistentID: UInt64, databaseInterface: DatabaseInterface) -> Song? {
        let songs:Array<Song> = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format: "summary.persistentID == %llu", persistentID)) as! Array<Song>
        if songs.count == 1 {
            return songs.first
        }
        
        return nil
    }
    
    class func fetchAllArtistsFromSongs(_ songsArray:Array<Song>, databaseInterface:DatabaseInterface) -> Array<Artist> {
        var returnValue = Array<Artist>()
        
        var currentSongArtistName:String
        
        for currentSong:Song in songsArray {
            currentSongArtistName = currentSong.albumArtistName
            if let currentArtist = ArtistFetcher.fetchArtistWithName(currentSongArtistName, databaseInterface:databaseInterface) {
                if !returnValue.contains(currentArtist) {
                    returnValue.append(currentArtist)
                }
            }
        }
        
        return returnValue
    }
    
    class func fetchPlaylistSongListPersistentKeysAndLastPlayedTimes(_ persistentId: UInt64) -> [SongPlayRecord] {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        guard let playlistSongSummaries = PlaylistFetcher.fetchPlaylistSongSummariesWithPersistentID(persistentId, databaseInterface: databaseInterface) else {
            return []
        }
        
        var returnValue: [SongPlayRecord] = []
        
        for songSummaryElement in playlistSongSummaries {
            if let songSummary = songSummaryElement as? SongSummary {
                let songPlayRecord = SongPlayRecord(persistentKey: songSummary.persistentKey, lastPlayedTime: songSummary.lastPlayedTime, title: songSummary.title)
                returnValue.append(songPlayRecord)
            }
        }
        Logger.logDetails(msg:"elapsed time = \(MillisecondTimer.secondsSince(startTime))")
        
        return returnValue
    }
    
    class func fetchSongListPersistentKeysAndLastPlayedTimes(_ predicate: NSPredicate?) -> [SongPlayRecord] {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let songSummaryDictionaries = databaseInterface.entitiesOfType("SongSummary", fetchRequestChangeBlock: { (inputFetchRequest) -> NSFetchRequest<NSManagedObject> in
            inputFetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            inputFetchRequest.returnsDistinctResults = true
            inputFetchRequest.propertiesToFetch = ["persistentKey", "lastPlayedTime", "title"]
            inputFetchRequest.predicate = predicate
            
            return inputFetchRequest
        }) as! Array<NSDictionary>
        
        var returnValue:[SongPlayRecord] = []
        for songSummaryDictionary in songSummaryDictionaries {
            if let persistentKeyNumber = songSummaryDictionary.object(forKey: "persistentKey") as? NSNumber {
                if let lastPlayedTimeNumber = songSummaryDictionary.object(forKey: "lastPlayedTime") as? NSNumber {
                    if let title = songSummaryDictionary.object(forKey: "title") as? String {
                        let songPlayRecord = SongPlayRecord(persistentKey: persistentKeyNumber.int64Value, lastPlayedTime: lastPlayedTimeNumber.doubleValue, title: title)
                        returnValue.append(songPlayRecord)
                    }
                }
            }
        }
        Logger.logDetails(msg:" elapsed time = \(MillisecondTimer.secondsSince(startTime))")
        
        return returnValue
    }
    
    class func fetchAllPlayedSongs(completionHandler: @escaping ([[String:String]]) -> ()) {
        let icDocWrapper = ICloudDocWrapper(filename: FileUtilities.iCloudPlayedSongsFileName())

        icDocWrapper.readDocText { (docResult, docText) in
            //Logger.logDetails(msg: "\(docText)")
            
            guard let docText = docText else {
                Logger.logDetails(msg: "docText is nil")
                return
            }
            
            let docLines = docText.components(separatedBy: "\n")
            
            var songSummaryDictionaries:[[String:String]] = []
            
            var titleString = ""
            var artistString = ""
            var albumString = ""
            var persistentKeyString = ""
            var lastPlayedTimeString = ""
            
            for (index, currentLine) in docLines.enumerated() {
                //print(currentLine)
                let currentLineTokens = currentLine.components(separatedBy:"\t")
                if currentLine != "" {
                    switch index % 6 {
                        
                    case 0:
                        titleString = currentLineTokens[1]
                    case 1:
                        artistString = currentLineTokens[1]
                    case 2:
                        albumString = currentLineTokens[1]
                    case 3:
                        persistentKeyString = currentLineTokens[1]
                    case 4:
                        lastPlayedTimeString = currentLineTokens[1]
                        /*
                         if (songSummaryDictionaries.indexOf({$0["persistentKey"] == persistentKeyString}) != nil) {
                         Logger.writeToLogFile("\(titleString) by \(artistString) has been played multiple times")
                         }
                         */
                        songSummaryDictionaries.append(["title": titleString,
                                                        "artist": artistString,
                                                        "album": albumString,
                                                        "persistentKey": persistentKeyString,
                                                        "lastPlayedTime": lastPlayedTimeString])
                    default:
                        break
                    }
                    
                }
            }
            
            completionHandler(songSummaryDictionaries)
        }
    }
    
}
