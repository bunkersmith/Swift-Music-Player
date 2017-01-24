//
//  SongDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

class SongDatabaseOperations: NSObject {
    
    weak var delegate:DatabaseProgressDelegate?

    func start(databaseInterface: DatabaseInterface, playedSongs: [[String : String]]) {
        let startTime = MillisecondTimer.currentTickCount()
        
        let songFactory = SongFactory()
        
        var progressFraction:Float
        
        // Fill in the all songs array with all the songs in the user's media library
        let allSongsQuery = MPMediaQuery.songs()
        if let mediaLibrarySongsArray:[MPMediaItem] = allSongsQuery.items {
            var songIndex:Int = 0
            
            for currentMediaItem:MPMediaItem in mediaLibrarySongsArray
            {
                guard currentMediaItem.assetURL != nil else {
                    Logger.writeToLogFile("currentMediaItem.assetURL == nil for song with  " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                    delegate?.progressUpdate(1.0, operationType: .songOperation)
                    return
                }
                
                guard var currentSongSummary = databaseInterface.newManagedObjectOfType("SongSummary") as? SongSummary else {
                    Logger.writeToLogFile("currentSongSummary == nil for song with  " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                    delegate?.progressUpdate(1.0, operationType: .songOperation)
                    return
                }
                
                guard var currentSong = databaseInterface.newManagedObjectOfType("Song") as? Song else {
                    Logger.writeToLogFile("currentSong == nil for song with " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                    delegate?.progressUpdate(1.0, operationType: .songOperation)
                    return
                }
                
                songFactory.populateSongSummary(&currentSongSummary, mediaItem: currentMediaItem)
                songFactory.populateSong(&currentSong, songURL: currentMediaItem.assetURL!, songSummary: currentSongSummary, mediaItem: currentMediaItem, databaseInterface: databaseInterface)
                databaseInterface.saveContext()
                
                if songIndex % 20 == 0 || songIndex == mediaLibrarySongsArray.count - 1 {
                    progressFraction = Float(songIndex + 1) / Float(mediaLibrarySongsArray.count)
                    delegate?.progressUpdate(progressFraction, operationType: .songOperation)
                }
                
                songIndex+=1
            }
        }
        
        SongsInterface.restoreSongsLastPlayedTimes(playedSongs: playedSongs, databaseInterface:databaseInterface)
        
        let songCount = databaseInterface.countOfEntitiesOfType("Song", predicate: nil)
        Logger.writeToLogFile("Song List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(songCount) songs")
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Swift-Music-Player.AllSongsTableNeedsReloadNotification" object:self userInfo:nil)
    }
}
