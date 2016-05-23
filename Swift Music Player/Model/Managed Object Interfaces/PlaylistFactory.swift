//
//  PlaylistFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class PlaylistFactory {
    
    func populatePlaylistSummary(inout playlistSummary:PlaylistSummary, playlistTitle:String, playlistPersistentID:UInt64) {
        playlistSummary.title = playlistTitle
        playlistSummary.searchKey = playlistTitle
        playlistSummary.persistentID = playlistPersistentID
    }
    
    func populatePlaylist(inout playlist:Playlist,
                         playlistSummary:PlaylistSummary,
                           mediaPlaylist:MPMediaPlaylist,
                         inout songIndex:Int,
                  totalPlaylistSongCount:Int,
                       databaseInterface:DatabaseInterface,
                       delegate: DatabaseProgressDelegate?) -> Bool {
        playlist.summary = playlistSummary
        
        for song:MPMediaItem in mediaPlaylist.items {
            let songTitle = song.title
            if songTitle != "" {
                let songSummaryObject = SongFetcher.fetchSongSummaryWithPersistentID(song.persistentID, databaseInterface: databaseInterface)
                if songSummaryObject != nil {
                    playlist.addSongSummariesObject(songSummaryObject!)
                }
                else {
                    Logger.writeToLogFile("Could not find song titled \(songTitle) in database")
                }
                
                if songIndex % 30 == 0 || songIndex == totalPlaylistSongCount - 1 {
                    let progressFraction = Float(songIndex + 1) / Float(totalPlaylistSongCount)
                    delegate?.progressUpdate(progressFraction, operationType: .PlaylistOperation)
                }
            }
            else {
                Logger.writeToLogFile("Error retrieving title for song with persistentID \(song.persistentID) for song in playlist titled \(playlist.summary.title)")
            }
            
            songIndex += 1
        }
        return true
    }
    
}