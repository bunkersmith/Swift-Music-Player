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
    
    class func returnAlbumReleaseYearString(albumMediaItem: MPMediaItem) -> String
    {
        if let releaseYearNumber:NSNumber = albumMediaItem.valueForProperty("year") as? NSNumber {
            return "Released \(releaseYearNumber.intValue)"
        }
        else {
            return "Unknown Release Year"
        }
    }
    
    class func returnAlbumPlaybackDuration(albumTracks: Array<MPMediaItem>) -> NSTimeInterval
    {
        var playbackDuration:NSTimeInterval = 0
        
        for track:MPMediaItem in albumTracks
        {
            playbackDuration += track.playbackDuration
        }
        
        return playbackDuration
    }
    
    class func persistentKeyForAlbum(album: Album, albumSummary: AlbumSummary, databaseInterface: DatabaseInterface) -> Int64 {
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
    
    class func tracksForAlbum(album: Album, albumSummary: AlbumSummary, databaseInterface: DatabaseInterface, albumSongMediaItems:Array<MPMediaItem>) -> Array<Song> {
        let albumTracks:Array<Song> = AlbumFetcher.fetchAlbumSongsByAlbumPersistentID(albumSummary.persistentID, databaseInterface: databaseInterface)
        
        if albumTracks.count != albumSongMediaItems.count {
            Logger.writeToLogFile("Media collection count (\(albumSongMediaItems.count)) differs from database track count (\(albumTracks.count)) for album " + albumSummary.title) // counts were %lu
        }
        return albumTracks
    }
    
    class func isInstrumentalValueForAlbum(album: Album, instrumentalAlbumsArray: Array<NSDictionary>) -> Bool {
        let dictionary: NSDictionary = ["Artist": album.summary.artistName,
                                        "Album": album.summary.title]
        return instrumentalAlbumsArray.indexOf(dictionary) != nil
    }
    
}