//
//  ArtistFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class ArtistFetcher {
    class func fetchArtistSummaryWithPersistentID(_ persistentID: UInt64, databaseInterface:DatabaseInterface) -> ArtistSummary? {
        let artistSummaries:Array<ArtistSummary> = databaseInterface.entitiesOfType("ArtistSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<ArtistSummary>
        if artistSummaries.count == 1 {
            return artistSummaries.first
        }
        
        return nil
    }
    
    class func fetchArtistWithName(_ artistName: String, databaseInterface:DatabaseInterface) -> Artist?
    {
        guard let artistObjects = databaseInterface.entitiesOfType("Artist", predicate:NSPredicate(format:"summary.name == %@", artistName)) as? Array<Artist> else {
            return nil
        }
        
        guard artistObjects.count == 1 else {
            return nil
        }
        
        return artistObjects.first
    }
    
    class func fetchMediaLibraryArtistAlbums(_ artistPersistentID: UInt64) -> Array<MPMediaItemCollection>
    {
        let artistAlbumsQuery = MPMediaQuery.albums()
        let albumPredicate = MPMediaPropertyPredicate(value: NSNumber(value: artistPersistentID as UInt64), forProperty: MPMediaItemPropertyAlbumArtistPersistentID)
        artistAlbumsQuery.addFilterPredicate(albumPredicate)
        
        if let artistAlbums:[MPMediaItemCollection] = artistAlbumsQuery.collections {
            return artistAlbums
        }
        Logger.writeToLogFile("Zero album media items returned for artist with persistentID \(artistPersistentID)")
        return Array<MPMediaItemCollection>()
    }
    
    class func fetchArtistAlbumsWithArtistPersistentID(_ artistPersistentID: UInt64, databaseInterface:DatabaseInterface) -> Array<Album>
    {
        guard var artistAlbums:Array<Album> = databaseInterface.entitiesOfType("Album", predicate: NSPredicate(format:"artistPersistentID == %llu", artistPersistentID)) as? Array<Album> else {
            Logger.writeToLogFile("Zero albums returned for artist with persistentID \(artistPersistentID)")
            return Array<Album>()
        }
        
        guard artistAlbums.count > 0 else {
            Logger.writeToLogFile("Zero albums returned for artist with persistentID \(artistPersistentID)")
            return Array<Album>()
        }
        
        artistAlbums = artistAlbums.sorted(by: {$0.summary.title < $1.summary.title})
        return artistAlbums
    }
    
}
