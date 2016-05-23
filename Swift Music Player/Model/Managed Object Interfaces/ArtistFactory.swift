//
//  ArtistFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class ArtistFactory {
    func populateArtistSummary(inout artistSummary:ArtistSummary, mediaItem:MPMediaItem, artistName:String) {
        artistSummary.name = artistName
        artistSummary.searchKey = artistName
        artistSummary.strippedName = MediaObjectUtilities.returnMediaObjectStrippedString(artistSummary.name)
        artistSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(artistSummary.strippedName)
        artistSummary.persistentID = mediaItem.albumArtistPersistentID
    }
    
    func populateArtist(inout artist:Artist, artistSummary:ArtistSummary, artistMediaItem:MPMediaItem, artistName:String, databaseInterface:DatabaseInterface) -> Bool {
        artist.summary = artistSummary
        
        let artistMediaAlbums = ArtistFetcher.fetchMediaLibraryArtistAlbums(artist.summary.persistentID)
        let artistCoreDataAlbums = ArtistFetcher.fetchArtistAlbumsWithArtistPersistentID(artist.summary.persistentID, databaseInterface:databaseInterface)
        
        if (artistMediaAlbums.count == artistCoreDataAlbums.count) {
            artist.addAlbumsObjects(artistCoreDataAlbums)
            return true
        }
        else
        {
            Logger.writeToLogFile("Media album count (\(artistMediaAlbums.count)) not equal to Core Data album count (\(artistCoreDataAlbums.count)) for artist " + artistName) // counts were %lu
        }
        return false
    }
    
    func processArtistMediaItem(artistMediaItem: MPMediaItem, databaseInterface:DatabaseInterface) {
        let artistName:String? = artistMediaItem.albumArtist
        if artistName == nil {
            Logger.writeToLogFile("artistName = NIL for artistMediaItem titled \(artistMediaItem.title)")
        }
        
        if artistName != nil && artistName != "" {
            if var artist = databaseInterface.newManagedObjectOfType("Artist") as? Artist {
                if var artistSummary:ArtistSummary = databaseInterface.newManagedObjectOfType("ArtistSummary") as? ArtistSummary {
                    populateArtistSummary(&artistSummary, mediaItem: artistMediaItem, artistName: artistName!)
                    if populateArtist(&artist, artistSummary: artistSummary, artistMediaItem: artistMediaItem, artistName: artistName!, databaseInterface:databaseInterface) {
                        databaseInterface.saveContext()
                    }
                }
                else {
                    Logger.writeToLogFile("artistSummary == nil for artist named " + artistName!)
                }
            }
        }
        else {
            Logger.writeToLogFile("Found a nil or blank artist name for artistMediaItem titled \(artistMediaItem.title)")
        }
    }
    
}