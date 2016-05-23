//
//  GenreFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class GenreFactory {
    
    func populateGenreSummary(inout genreSummary:GenreSummary, genreName:String, genrePersistentID:UInt64) {
        genreSummary.name = genreName
        genreSummary.searchKey = genreName
        genreSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(genreSummary.name)
        genreSummary.persistentID = genrePersistentID
    }
    
    func populateGenre(inout genre:Genre, genreSummary:GenreSummary, mediaCollection:MPMediaItemCollection, databaseInterface:DatabaseInterface) {
        genre.summary = genreSummary
        
        let genreSongs:Array<Song> = GenreFetcher.fetchGenreSongsWithGenreName(genreSummary.name, databaseInterface:databaseInterface)
        
        let genreArtists:Array<Artist> = SongFetcher.fetchAllArtistsFromSongs(genreSongs, databaseInterface:databaseInterface)
        
        if (genreSongs.count == mediaCollection.items.count) {
            genre.addArtistsObjects(genreArtists)
        }
        else {
            Logger.writeToLogFile("Media collection count (\(mediaCollection.items.count)) differs from database song count (%\(genreSongs.count)) for genre " + genreSummary.name)
        }
    }
    
    func processGenreMediaItem(genreMediaItem: MPMediaItem, genreMediaCollection:MPMediaItemCollection, databaseInterface:DatabaseInterface) -> Bool {
        if var genreSummary = databaseInterface.newManagedObjectOfType("GenreSummary") as? GenreSummary {
            if var genre = databaseInterface.newManagedObjectOfType("Genre") as? Genre {
                populateGenreSummary(&genreSummary, genreName: genreMediaItem.genre!, genrePersistentID: genreMediaItem.genrePersistentID)
                populateGenre(&genre, genreSummary: genreSummary, mediaCollection: genreMediaCollection, databaseInterface: databaseInterface)
                return true
            }
            else {
                Logger.writeToLogFile("currentGenre == nil for genre name \(genreMediaItem.genre)")
            }
        }
        else {
            Logger.writeToLogFile("currentGenreSummary == nil for genre name \(genreMediaItem.genre)")
        }
        return false
    }
    
}