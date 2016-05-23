//
//  AlbumFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

class AlbumFetcher {
    
    class func fetchAlbumByAlbumPersistentID(persistentID: UInt64, databaseInterface:DatabaseInterface) -> Album? {
        let albumObjects:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"summary.persistentID == %llu", persistentID)) as! Array<Album>
        
        if albumObjects.count == 1 {
            return albumObjects.first
        }
        return nil
    }
    
    class func fetchAlbumByAlbumPersistentKey(persistentKey: Int64, databaseInterface:DatabaseInterface) -> Album? {
        let albumObjects:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"persistentKey == %lld", persistentKey)) as! Array<Album>
        
        if albumObjects.count == 1 {
            return albumObjects.first
        }
        return nil
    }
    
    class func fetchAlbumSongsByAlbumPersistentID(persistentID: UInt64, databaseInterface:DatabaseInterface) -> Array<Song> {
        if var songObjects = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format:"albumPersistentID == %llu", persistentID)) as? Array<Song> {
            if songObjects.count > 0 {
                songObjects.sortInPlace({ $0.trackNumber < $1.trackNumber })
            }
            else
            {
                Logger.writeToLogFile("Zero songs returned for album with persistentID \(persistentID)")
            }
            
            return songObjects
        }
        return Array<Song>()
    }
    
}