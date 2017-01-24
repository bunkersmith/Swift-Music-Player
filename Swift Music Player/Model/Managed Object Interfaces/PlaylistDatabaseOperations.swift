//
//  PlaylistDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class PlaylistDatabaseOperations: NSObject {

    weak var delegate:DatabaseProgressDelegate?
    
    func start(databaseInterface: DatabaseInterface) {
        let startTime = MillisecondTimer.currentTickCount()
        
        let playlistsQuery = MPMediaQuery.playlists()
        guard let playlists = playlistsQuery.collections as? Array<MPMediaPlaylist> else {
            Logger.writeToLogFile("Playlist collections fech failed")
            delegate?.progressUpdate(1.0, operationType: .playlistOperation)
            return
        }
        
        var songIndex = 0
        let totalPlaylistSongCount = PlaylistsInterface.returnTotalPlaylistsSongCount(playlists)
        
        let playlistFactory = PlaylistFactory()
        
        for playlist:MPMediaPlaylist in playlists {
            guard playlist.name != nil && playlist.name != "" else {
                Logger.writeToLogFile("Error retrieving playlist title")
                delegate?.progressUpdate(1.0, operationType: .playlistOperation)
                return
            }
            
            if playlist.items.count > 0 {
                guard var playlistSummary = databaseInterface.newManagedObjectOfType("PlaylistSummary") as? PlaylistSummary else {
                    Logger.writeToLogFile("playlistSummary == nil for playlist with title \(playlist.name)")
                    delegate?.progressUpdate(1.0, operationType: .playlistOperation)
                    return
                }
                
                guard var playlistObject = databaseInterface.newManagedObjectOfType("Playlist") as? Playlist else {
                    Logger.writeToLogFile("playlistObject == nil for playlist with title \(playlist.name)")
                    delegate?.progressUpdate(1.0, operationType: .playlistOperation)
                    return
                }
                
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
        }
        
        let playlistSongsCount = PlaylistsInterface.returnTotalCoreDataPlaylistsSongCount(databaseInterface)
        Logger.writeToLogFile("Playlist List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(playlistSongsCount) total playlist songs")
    }
}

