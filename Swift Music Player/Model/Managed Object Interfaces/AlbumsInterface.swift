//
//  AlbumsInterface.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class AlbumsInterface {
    
    class func returnAlbumReleaseYearString(_ albumMediaItem: MPMediaItem) -> String
    {
        if let releaseYearNumber:NSNumber = albumMediaItem.value(forProperty: "year") as? NSNumber {
            return "Released \(releaseYearNumber.int32Value)"
        }
        else {
            return "Unknown Release Year"
        }
    }
    
    class func returnAlbumPlaybackDuration(_ albumTracks: Array<MPMediaItem>) -> TimeInterval
    {
        var playbackDuration:TimeInterval = 0
        
        for track:MPMediaItem in albumTracks
        {
            playbackDuration += track.playbackDuration
        }
        
        return playbackDuration
    }
    
    class func persistentKeyForAlbum(_ album: Album, albumSummary: AlbumSummary, databaseInterface: DatabaseInterface) -> Int64 {
        let albumKey = albumSummary.title.hash ^ album.duration.hashValue ^ album.releaseYearString.hash
        let existingAlbum = AlbumFetcher.fetchAlbumByAlbumPersistentKey(Int64(albumKey), databaseInterface: databaseInterface)
        if existingAlbum == nil {
            return Int64(albumKey)
        }
        else {
            Logger.writeToLogFile("Persistent key for album \(album) is a duplicate to an existing value \(albumKey) for album titled \(existingAlbum!.summary.title)")
        }
        return -1
    }
    
    class func tracksForAlbum(_ album: Album, albumSummary: AlbumSummary, databaseInterface: DatabaseInterface, albumSongMediaItems:Array<MPMediaItem>) -> Array<Song> {
        let albumTracks:Array<Song> = AlbumFetcher.fetchAlbumSongsByAlbumPersistentID(albumSummary.persistentID, databaseInterface: databaseInterface)
        
        if albumTracks.count != albumSongMediaItems.count {
            Logger.writeToLogFile("Media collection count (\(albumSongMediaItems.count)) differs from database track count (\(albumTracks.count)) for album " + albumSummary.title) // counts were %lu
        }
        return albumTracks
    }
    
    class func isInstrumentalValueForAlbum(_ album: Album, instrumentalAlbumsArray: Array<NSDictionary>) -> Bool {
        let dictionary: NSDictionary = ["Artist": album.summary.artistName,
                                        "Album": album.summary.title]
        return instrumentalAlbumsArray.index(of: dictionary) != nil
    }
    
    class func artworkForAlbum(_ album: Album?, size: CGSize) -> UIImage {
        guard album != nil else {
            return UIImage(named: "no-album-artwork.png")!
        }
        
        guard let albumArtwork = album!.albumArtwork(DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)) else {
            return UIImage(named: "no-album-artwork.png")!
        }
        
        guard let albumArtworkImage = albumArtwork.image(at: albumArtwork.bounds.size) else {
            return UIImage(named: "no-album-artwork.png")!
        }
        
        let scaledAlbumArtworkImage = albumArtworkImage.scaleToSize(size)
        return scaledAlbumArtworkImage
    }
    
    class func numberOfAlbumsInDatabase(_ databaseInterface: DatabaseInterface) -> Int {
        return databaseInterface.countOfEntitiesOfType("Album", predicate: nil)
    }
    
}
