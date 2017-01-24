//
//  AlbumFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class AlbumFactory {
    
    func populateAlbumSummary(_ albumSummary:inout AlbumSummary, mediaItem:MPMediaItem, albumTitle:String, albumArtistName:String, albumPersistentID:UInt64) {
        albumSummary.title = albumTitle
        albumSummary.searchKey = albumTitle
        albumSummary.strippedTitle = MediaObjectUtilities.returnMediaObjectStrippedString(albumSummary.title)
        albumSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(albumSummary.strippedTitle)
        albumSummary.artistName = albumArtistName
        albumSummary.persistentID = albumPersistentID
    }
    
    func populateAlbum(_ album:inout Album,
                             albumSummary:AlbumSummary,
                             mediaItem:MPMediaItem,
                             artistPersistentID:UInt64,
                             albumSongMediaItems:Array<MPMediaItem>,
                             albumIndex:Int16,
                             instrumentalAlbums: Array<NSDictionary>,
                             databaseInterface:DatabaseInterface) {
        album.artistPersistentID = artistPersistentID
        album.internalID = albumIndex
        album.releaseYearString = AlbumsInterface.returnAlbumReleaseYearString(mediaItem)
        album.duration = AlbumsInterface.returnAlbumPlaybackDuration(albumSongMediaItems)
        album.persistentKey = AlbumsInterface.persistentKeyForAlbum(album, albumSummary: albumSummary, databaseInterface: databaseInterface)
        album.addSongsObjects(AlbumsInterface.tracksForAlbum(album, albumSummary: albumSummary, databaseInterface: databaseInterface, albumSongMediaItems: albumSongMediaItems) as NSArray as NSArray)
        album.summary = albumSummary
        album.isInstrumental = AlbumsInterface.isInstrumentalValueForAlbum(album, instrumentalAlbumsArray: instrumentalAlbums)
     }
    
    func processAlbumMediaItem(_ albumMediaItem: MPMediaItem, albumSongMediaItems: Array<MPMediaItem>, albumIndex: Int16, instrumentalAlbums: Array<NSDictionary>, databaseInterface: DatabaseInterface) -> Bool {
        let currentAlbumArtistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(albumMediaItem.albumArtist as AnyObject?)
        if currentAlbumArtistName == "" {
            Logger.writeToLogFile("currentAlbumArtistName is nil for album titled \(albumMediaItem.albumTitle)")
        }
        
        guard var currentAlbumSummary:AlbumSummary = databaseInterface.newManagedObjectOfType("AlbumSummary") as? AlbumSummary else {
            Logger.writeToLogFile("currentAlbumSummary == nil for album with %" + MediaObjectUtilities.titleAndArtistStringForMediaItem(albumMediaItem))
            return false
        }
        
        guard var currentAlbum:Album = databaseInterface.newManagedObjectOfType("Album") as? Album else {
            Logger.writeToLogFile("currentAlbum == nil for album with %@" + MediaObjectUtilities.titleAndArtistStringForMediaItem(albumMediaItem))
            return false
        }
        
        populateAlbumSummary(&currentAlbumSummary, mediaItem: albumMediaItem, albumTitle:albumMediaItem.albumTitle!, albumArtistName:currentAlbumArtistName, albumPersistentID: albumMediaItem.albumPersistentID)
        populateAlbum(&currentAlbum,
                      albumSummary: currentAlbumSummary,
                      mediaItem: albumMediaItem,
                      artistPersistentID: albumMediaItem.albumArtistPersistentID,
                      albumSongMediaItems: albumSongMediaItems,
                      albumIndex: albumIndex,
                      instrumentalAlbums: instrumentalAlbums,
                      databaseInterface: databaseInterface)
        
        //Logger.writeToLogFile("\(currentAlbum)")
        return true
    }
}
