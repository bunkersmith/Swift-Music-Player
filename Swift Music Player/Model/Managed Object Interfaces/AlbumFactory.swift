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
    
    class func populateAlbumSummary(inout albumSummary:AlbumSummary, mediaItem:MPMediaItem, albumTitle:String, albumArtistName:String, albumPersistentID:UInt64) {
        albumSummary.title = albumTitle
        albumSummary.searchKey = albumTitle
        albumSummary.strippedTitle = MediaObjectUtilities.returnMediaObjectStrippedString(albumSummary.title)
        albumSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(albumSummary.strippedTitle)
        albumSummary.artistName = albumArtistName
        albumSummary.persistentID = albumPersistentID
    }
    
    class func populateAlbum(inout album:Album,
                             albumSummary:AlbumSummary,
                             mediaItem:MPMediaItem,
                             artistPersistentID:UInt64,
                             albumSongMediaItems:Array<MPMediaItem>,
                             albumIndex:Int16,
                             databaseInterface:DatabaseInterface) {
        album.artistPersistentID = artistPersistentID
        album.internalID = albumIndex
        album.releaseYearString = AlbumsInterface.returnAlbumReleaseYearString(mediaItem)
        album.duration = AlbumsInterface.returnAlbumPlaybackDuration(albumSongMediaItems)
        album.persistentKey = AlbumsInterface.persistentKeyForAlbum(album, albumSummary: albumSummary, databaseInterface: databaseInterface)
        //album.isInstrumental = isInstrumentalValueForAlbum(album, userPreferences: userPreferences)
        album.addSongsObjects(AlbumsInterface.tracksForAlbum(album, albumSummary: albumSummary, databaseInterface: databaseInterface, albumSongMediaItems: albumSongMediaItems))
        album.summary = albumSummary
    }
    
    class func processAlbumMediaItem(albumMediaItem: MPMediaItem, albumSongMediaItems: Array<MPMediaItem>, albumIndex: Int16, databaseInterface: DatabaseInterface) -> Bool {
        let currentAlbumArtistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(albumMediaItem.albumArtist)
        if currentAlbumArtistName == "" {
            Logger.writeToLogFile("currentAlbumArtistName is nil for album titled \(albumMediaItem.albumTitle)")
        }
        
        if var currentAlbumSummary:AlbumSummary = databaseInterface.newManagedObjectOfType("AlbumSummary") as? AlbumSummary {
            if var currentAlbum:Album = databaseInterface.newManagedObjectOfType("Album") as? Album {
                populateAlbumSummary(&currentAlbumSummary, mediaItem: albumMediaItem, albumTitle:albumMediaItem.albumTitle!, albumArtistName:currentAlbumArtistName, albumPersistentID: albumMediaItem.albumPersistentID)
                populateAlbum(&currentAlbum,
                              albumSummary: currentAlbumSummary,
                              mediaItem: albumMediaItem,
                              artistPersistentID: albumMediaItem.albumArtistPersistentID,
                              albumSongMediaItems: albumSongMediaItems,
                              albumIndex: albumIndex,
                              databaseInterface: databaseInterface)
                
                //Logger.writeToLogFile("\(currentAlbum)")
                return true
            }
            else {
                Logger.writeToLogFile("currentAlbum == nil for album with %@" + MediaObjectUtilities.titleAndArtistStringForMediaItem(albumMediaItem))
            }
        }
        else {
            Logger.writeToLogFile("currentAlbumSummary == nil for album with %" + MediaObjectUtilities.titleAndArtistStringForMediaItem(albumMediaItem))
        }
        
        return false
    }
    
    // THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
    class func fillDatabaseAlbumsFromItunesLibrary() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        let albumsQuery = MPMediaQuery.albumsQuery()
        if let albumsCollection:[MPMediaItemCollection]? = albumsQuery.collections {
            
            var albumIndex: Int = 0
            var progressFraction: Float
            
            for currentMediaCollection:MPMediaItemCollection in albumsCollection!
            {
                let albumSongMediaItems = currentMediaCollection.items
                if processAlbumMediaItem(currentMediaCollection.representativeItem!, albumSongMediaItems: albumSongMediaItems, albumIndex:Int16(albumIndex), databaseInterface: databaseInterface) {
                    databaseInterface.saveContext()
                }
                
                if albumIndex % 10 == 0 || albumIndex == albumsCollection!.count - 1 {
                    progressFraction = Float(albumIndex + 1) / Float(albumsCollection!.count)
                    NSLog("progressFraction: \(progressFraction)")
                    //delegate?.progressUpdate(progressFraction, operationType: .AlbumOperation)
                }
                
                albumIndex+=1
            }
        }
        else {
            Logger.writeToLogFile("Albums query failed")
        }
        
        Logger.writeToLogFile("Album List Build Time: \(MillisecondTimer.secondsSince(startTime))")
        //Logger.writeToLogFile("instrumentalAlbumCount = \(instrumentalAlbumCount)")
        
        //[self performSelectorOnMainThread:@selector(sendAlbumsTableNeedsReloadNotification) withObject:nil waitUntilDone:NO]
    }
}