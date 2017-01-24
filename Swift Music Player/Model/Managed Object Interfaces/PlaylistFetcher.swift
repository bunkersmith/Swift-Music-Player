//
//  PlaylistFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

class PlaylistFetcher {
    
    class func fetchPlaylistSummaryWithPersistentID(_ persistentID: UInt64, databaseInterface: DatabaseInterface) -> PlaylistSummary? {
        let playlistSummaries:Array<PlaylistSummary> = databaseInterface.entitiesOfType("PlaylistSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<PlaylistSummary>
        if playlistSummaries.count == 1 {
            return playlistSummaries.first
        }
        
        return nil
    }
    
    class func fetchPlaylistSongSummariesWithPersistentID(_ persistentID: UInt64, databaseInterface: DatabaseInterface) -> NSOrderedSet? {
        let playlists:Array<Playlist> = databaseInterface.entitiesOfType("Playlist", predicate: NSPredicate(format: "summary.persistentID == %llu", persistentID)) as! Array<Playlist>
        guard playlists.count == 1 else {
            return nil
        }
        
        guard let playlist = playlists.first else {
            return nil
        }
        
        //NSLog("playlist.songSummaries = \(playlist.songSummaries)")
        
        return playlist.songSummaries
    }
    
    class func fetchPlaylistSummaryWithPlaylistTitle(_ playlistTitle: String, databaseInterface: DatabaseInterface) -> PlaylistSummary? {
        let playlistSummaries:Array<PlaylistSummary> = databaseInterface.entitiesOfType("PlaylistSummary", predicate: NSPredicate(format: "title == %@", playlistTitle)) as! Array<PlaylistSummary>
        if playlistSummaries.count == 1 {
            return playlistSummaries.first
        }
        
        return nil
    }
    
}
