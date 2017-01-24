//
//  SongsInterface.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class SongsInterface {
    
    class func persistentKeyForSong(_ song: Song, songSummary: SongSummary, databaseInterface: DatabaseInterface) -> Int64 {
        let songKey = songSummary.title.hash ^ songSummary.artistName.hash ^ song.albumTitle.hash ^ song.duration.hashValue
        let existingSong = SongFetcher.fetchSongBySongPersistentKey(Int64(songKey), databaseInterface: databaseInterface)
        if existingSong == nil {
            return Int64(songKey)
        }
        else {
            Logger.writeToLogFile("Persistent key for song \(song) is a duplicate to an existing value \(songKey) for song titled \(existingSong!.summary.title)")
        }
        return -1
    }
    
    class func totalSongCount() -> Int {
        return DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).countOfEntitiesOfType("SongSummary", predicate: nil)
    }

    // THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
    class func restoreSongsLastPlayedTimes(playedSongs: [[String:String]], databaseInterface: DatabaseInterface) {
        var restoredSongCount = 0
        for songDictionary:Dictionary in playedSongs {
            if let persistentKeyString = songDictionary["persistentKey"] {
                if let persistentKeyNumber = NumberFormatter().number(from: persistentKeyString) {
                    if let lastPlayedTimeString = songDictionary["lastPlayedTime"] {
                        if let lastPlayedTimeNumber = NumberFormatter().number(from: lastPlayedTimeString) {
                            if let song = SongFetcher.fetchSongBySongPersistentKey(persistentKeyNumber.int64Value, databaseInterface: databaseInterface) {
                                song.summary.lastPlayedTime = lastPlayedTimeNumber.doubleValue
                                databaseInterface.saveContext()
                                restoredSongCount += 1
                            }
                        }
                    }
                }
            }
        }
        Logger.writeToLogFile("restoreSongsLastPlayedTimes restored \(restoredSongCount) songs")
    }
    
}
