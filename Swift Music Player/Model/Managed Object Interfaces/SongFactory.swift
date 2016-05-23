//
//  SongFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class SongFactory {

    var delegate:DatabaseProgressDelegate?
    
    func populateSongSummary(inout songSummary:SongSummary, mediaItem:MPMediaItem) {
        songSummary.artistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.artist)
        songSummary.title = mediaItem.title!
        songSummary.searchKey = songSummary.title
        songSummary.strippedTitle = MediaObjectUtilities.returnMediaObjectStrippedString(songSummary.title)
        songSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(songSummary.strippedTitle)
        songSummary.persistentID = mediaItem.persistentID
        songSummary.lastPlayedTime = 0
    }
    
    func populateSong(inout song:Song, songURL:NSURL, songSummary:SongSummary, mediaItem:MPMediaItem, databaseInterface: DatabaseInterface) {
        song.albumPersistentID = mediaItem.albumPersistentID
        song.assetURL = NSKeyedArchiver.archivedDataWithRootObject(songURL)
        song.duration = mediaItem.playbackDuration
        song.albumArtistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.albumArtist)
        song.albumTitle = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.albumTitle)
        song.genreName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.genre)
        song.trackNumber = UInt64(mediaItem.albumTrackNumber)
        songSummary.persistentKey = SongsInterface.persistentKeyForSong(song, songSummary: songSummary, databaseInterface: databaseInterface)
        song.summary = songSummary
    }

    
    // THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
    func fillDatabaseSongsFromItunesLibrary() {
        guard !NSThread.isMainThread() else { return }
        
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        var progressFraction:Float
        
        // Fill in the all songs array with all the songs in the user's media library
        let allSongsQuery = MPMediaQuery.songsQuery()
        if let mediaLibrarySongsArray:[MPMediaItem]? = allSongsQuery.items {
            var songIndex:Int = 0
            
            for currentMediaItem:MPMediaItem in mediaLibrarySongsArray!
            {
                if currentMediaItem.assetURL != nil {
                    if var currentSongSummary = databaseInterface.newManagedObjectOfType("SongSummary") as? SongSummary {
                        if var currentSong = databaseInterface.newManagedObjectOfType("Song") as? Song {
                            populateSongSummary(&currentSongSummary, mediaItem: currentMediaItem)
                            populateSong(&currentSong, songURL: currentMediaItem.assetURL!, songSummary: currentSongSummary, mediaItem: currentMediaItem, databaseInterface: databaseInterface)
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
        
        Logger.writeToLogFile("Song List Build Time: \(MillisecondTimer.secondsSince(startTime))") // was %.3f
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Swift-Music-Player.AllSongsTableNeedsReloadNotification" object:self userInfo:nil)
    }
}