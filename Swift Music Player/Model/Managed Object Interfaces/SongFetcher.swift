//
//  SongFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

class SongFetcher {
    
    class func fetchSongBySongPersistentKey(persistentKey: Int64, databaseInterface:DatabaseInterface) -> Song? {
        let songObjects:Array<Song> = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format: "summary.persistentKey == %lld", persistentKey)) as! Array<Song>
        
        if songObjects.count == 1 {
            return songObjects.first
        }
        return nil
    }
    
    class func fetchSongByTitleArtistAndAlbum(title: String, artistName: String, albumTitle: String) -> Song? {
        let databaseInterface = DatabaseInterface(forMainThread: true)
        let predicate = NSPredicate(format: "summary.title == %@ AND summary.artistName = %@ AND albumTitle = %@", title, artistName, albumTitle)
        
        let songObjects:Array<Song> = databaseInterface.entitiesOfType("Song", predicate: predicate) as! Array<Song>
        if songObjects.count == 1 {
            return songObjects.first
        }
        
        return nil
    }
    
}