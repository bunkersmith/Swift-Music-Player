//
//  AlbumFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class AlbumFetcher {
    
    class func fetchAlbumByAlbumPersistentID(_ persistentID: UInt64, databaseInterface:DatabaseInterface) -> Album? {
        let albumObjects:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"summary.persistentID == %llu", persistentID)) as! Array<Album>
        
        if albumObjects.count == 1 {
            return albumObjects.first
        }
        return nil
    }
    
    class func fetchAlbumByAlbumPersistentKey(_ persistentKey: Int64, databaseInterface:DatabaseInterface) -> Album? {
        let albumObjects:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"persistentKey == %lld", persistentKey)) as! Array<Album>
        
        if albumObjects.count == 1 {
            return albumObjects.first
        }
        return nil
    }
    
    class func fetchAlbumSongsByAlbumPersistentID(_ persistentID: UInt64, databaseInterface:DatabaseInterface) -> Array<Song> {
        guard var songObjects = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format:"albumPersistentID == %llu", persistentID)) as? Array<Song> else {
            return Array<Song>()
        }
        
        guard songObjects.count > 0 else {
            Logger.writeToLogFile("Zero songs returned for album with persistentID \(persistentID)")
            return Array<Song>()
        }
        
        songObjects.sort(by: { $0.trackNumber < $1.trackNumber })
        return songObjects
    }
    
    class func fetchAlbumSummaryWithPersistentID(_ persistentID: UInt64) -> AlbumSummary? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let albumSummaries:Array<AlbumSummary> = databaseInterface.entitiesOfType("AlbumSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<AlbumSummary>
        if albumSummaries.count == 1 {
            return albumSummaries.first
        }
        
        return nil
    }
    
    class func fetchAlbumWithInternalID(_ albumInternalID: NSInteger, databaseInterface: DatabaseInterface) -> Album?
    {
        if let albumObjects = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format: "internalID == %@", NSNumber(value: albumInternalID as Int))) as? Array<Album> {
            if albumObjects.count == 1 {
                return albumObjects.first
            }
        }
        return nil
    }
    
    class func fetchAlbumImageWithAlbumInternalID(_ internalID: NSInteger, size:CGSize, databaseInterface: DatabaseInterface) -> UIImage
    {
        if let album:Album = fetchAlbumWithInternalID(internalID, databaseInterface:databaseInterface) {
            if let localAlbumArtwork:MPMediaItemArtwork = album.albumArtwork(databaseInterface) {
                return localAlbumArtwork.image(at: size)!
            }
        }
        
        let noArtworkImage = UIImage(named: "no-album-artwork.png")!
        return noArtworkImage.scaleToSize(size)
    }
    
    class func fetchAlbumTextDataWithAlbumInternalID(_ internalID: NSInteger, albumTitleString: inout String, albumArtistString: inout String, songTitleString: inout String, databaseInterface:DatabaseInterface)
    {
        albumTitleString = ""
        albumArtistString = ""
        songTitleString = ""
        
        if let album:Album = fetchAlbumWithInternalID(internalID, databaseInterface:databaseInterface) {
            albumTitleString = album.summary.title
            albumArtistString = album.summary.artistName
            
            if let currentSong:Song = SongManager.instance.song {
                if currentSong.albumTitle == album.summary.title &&
                    currentSong.albumArtistName == album.artist!.summary.name
                {
                    songTitleString = currentSong.summary.title
                }
            }
        }
    }
    
    class func fetchAlbumByTitleAndArtist(_ title: String, artistName: String, databaseInterface: DatabaseInterface) -> Album? {
        let predicate = NSPredicate(format: "summary.title == %@ AND summary.artistName = %@", title, artistName)
        
        let albumObjects:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: predicate) as! Array<Album>
        if albumObjects.count == 1 {
            return albumObjects.first
        }
        
        return nil
    }
    
}
