//
//  PlaylistDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class PlaylistDatabaseOperations: NSOperation {

    var delegate:DatabaseProgressDelegate?
    
    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let playlistsQuery = MPMediaQuery.playlistsQuery()
        if let playlists = playlistsQuery.collections as? Array<MPMediaPlaylist> {
            var songIndex = 0
            let totalPlaylistSongCount = PlaylistsInterface.returnTotalPlaylistsSongCount(playlists)
            
            let databaseInterface = DatabaseInterface(forMainThread: false)
            let playlistFactory = PlaylistFactory()
            
            for playlist:MPMediaPlaylist in playlists {
                if playlist.name != nil && playlist.name != "" {
                    if playlist.items.count > 0 {
                        if var playlistSummary = databaseInterface.newManagedObjectOfType("PlaylistSummary") as? PlaylistSummary {
                            if var playlistObject = databaseInterface.newManagedObjectOfType("Playlist") as? Playlist {
                                playlistFactory.populatePlaylistSummary(&playlistSummary, playlistTitle: playlist.name!, playlistPersistentID:playlist.persistentID)
                                if playlistFactory.populatePlaylist(&playlistObject,
                                                    playlistSummary: playlistSummary,
                                                    mediaPlaylist: playlist,
                                                    songIndex: &songIndex,
                                                    totalPlaylistSongCount:totalPlaylistSongCount,
                                                    databaseInterface:databaseInterface,
                                                    delegate: delegate) {
                                    databaseInterface.saveContext()
                                    //Logger.writeToLogFile("\(playlistObject)")
                                }
                            }
                            else {
                                Logger.writeToLogFile("playlistObject == nil for playlist with title \(playlist.name)")
                            }
                        }
                        else {
                            Logger.writeToLogFile("playlistSummary == nil for playlist with title \(playlist.name)")
                        }
                    }
                }
                else {
                    Logger.writeToLogFile("Error retrieving playlist title")
                }
            }
        }
        else {
            Logger.writeToLogFile("Playlist collections fech failed")
        }
        
        let playlistSongsCount = PlaylistsInterface.returnTotalCoreDataPlaylistsSongCount(DatabaseInterface(forMainThread: false))
        Logger.writeToLogFile("Playlist List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(playlistSongsCount) total playlist songs")
    }
}
