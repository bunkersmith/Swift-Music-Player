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
    
    class func persistentKeyForSong(song: Song, songSummary: SongSummary, databaseInterface: DatabaseInterface) -> Int64 {
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
}