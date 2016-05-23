//
//  SongDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

class SongDatabaseOperations: NSOperation {
    
    var delegate:DatabaseProgressDelegate?

    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        let songFactory = SongFactory()
        
        var progressFraction:Float
        
        // Fill in the all songs array with all the songs in the user's media library
        let allSongsQuery = MPMediaQuery.songsQuery()
        if let mediaLibrarySongsArray:[MPMediaItem]? = allSongsQuery.items {
            var songIndex:Int = 0
            
            for currentMediaItem:MPMediaItem in mediaLibrarySongsArray!
            {
                if cancelled {
                    return
                }
                
                if currentMediaItem.assetURL != nil {
                    if var currentSongSummary = databaseInterface.newManagedObjectOfType("SongSummary") as? SongSummary {
                        if var currentSong = databaseInterface.newManagedObjectOfType("Song") as? Song {
                            songFactory.populateSongSummary(&currentSongSummary, mediaItem: currentMediaItem)
                            songFactory.populateSong(&currentSong, songURL: currentMediaItem.assetURL!, songSummary: currentSongSummary, mediaItem: currentMediaItem, databaseInterface: databaseInterface)
                            databaseInterface.saveContext()
                        }
                        else {
                            Logger.writeToLogFile("currentSong == nil for song with " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                        }
                    }
                    else {
                        Logger.writeToLogFile("currentSongSummary == nil for song with  " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                    }
                }
                else {
                    Logger.writeToLogFile("currentMediaItem.assetURL == nil for song with  " + MediaObjectUtilities.titleAndArtistStringForMediaItem(currentMediaItem))
                }
                
                if songIndex % 20 == 0 || songIndex == mediaLibrarySongsArray!.count - 1 {
                    progressFraction = Float(songIndex + 1) / Float(mediaLibrarySongsArray!.count)
                    delegate?.progressUpdate(progressFraction, operationType: .SongOperation)
                }
                
                songIndex+=1
            }
        }
        
        let songCount = databaseInterface.countOfEntitiesOfType("Song", predicate: nil)
        Logger.writeToLogFile("Song List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(songCount) songs")
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Swift-Music-Player.AllSongsTableNeedsReloadNotification" object:self userInfo:nil)
    }
}
