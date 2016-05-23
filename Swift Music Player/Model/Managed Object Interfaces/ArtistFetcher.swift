//
//  ArtistFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class ArtistFetcher {
    class func fetchArtistSummaryWithPersistentID(persistentID: UInt64, databaseInterface:DatabaseInterface) -> ArtistSummary? {
        let artistSummaries:Array<ArtistSummary> = databaseInterface.entitiesOfType("ArtistSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<ArtistSummary>
        if artistSummaries.count == 1 {
            return artistSummaries.first
        }
        
        return nil
    }
    
    class func fetchArtistWithName(artistName: String, databaseInterface:DatabaseInterface) -> Artist?
    {
        if let artistObjects = databaseInterface.entitiesOfType("Artist", predicate:NSPredicate(format:"summary.name == %@", artistName)) as? Array<Artist> {
            if artistObjects.count == 1 {
                return artistObjects.first
            }
        }
        return nil
    }
    
    class func fetchMediaLibraryArtistAlbums(artistPersistentID: UInt64) -> Array<MPMediaItemCollection>
    {
        let artistAlbumsQuery = MPMediaQuery.albumsQuery()
        let albumPredicate = MPMediaPropertyPredicate(value: NSNumber(unsignedLongLong: artistPersistentID), forProperty: MPMediaItemPropertyAlbumArtistPersistentID)
        artistAlbumsQuery.addFilterPredicate(albumPredicate)
        
        if let artistAlbums:[MPMediaItemCollection]? = artistAlbumsQuery.collections {
            return artistAlbums!
        }
        Logger.writeToLogFile("Zero album media items returned for artist with persistentID \(artistPersistentID)")
        return Array<MPMediaItemCollection>()
    }
    
    class func fetchArtistAlbumsWithArtistPersistentID(artistPersistentID: UInt64, databaseInterface:DatabaseInterface) -> Array<Album>
    {
        if var artistAlbums:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"artistPersistentID == %llu", artistPersistentID)) as? Array<Album> {
            if artistAlbums.count > 0 {
                artistAlbums = artistAlbums.sort({$0.summary.title < $1.summary.title})
                return artistAlbums
            }
        }
        Logger.writeToLogFile("Zero albums returned for artist with persistentID \(artistPersistentID)")
        return Array<Album>()
    }
    
}