//
//  PlaylistsInterface.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class PlaylistsInterface {
    
    class func returnTotalPlaylistsSongCount(_ playlists:Array<MPMediaPlaylist>) -> Int {
        var totalSongCount:Int = 0
        
        for playlist:MPMediaPlaylist in playlists
        {
            totalSongCount += playlist.count
        }
        
        return totalSongCount
    }
    
    class func returnTotalCoreDataPlaylistsSongCount(_ databaseInterface: DatabaseInterface) -> Int {
        let playlistObjects:Array<Playlist> = databaseInterface.entitiesOfType("Playlist", predicate: nil) as! Array<Playlist>
        
        guard playlistObjects.count > 0 else {
            return 0
        }
        
        var returnValue = 0
        for playlistObject in playlistObjects {
            returnValue += playlistObject.songSummaries.count
        }
        
        return returnValue
    }
}
