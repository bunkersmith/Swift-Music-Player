//
//  SongFactory.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class SongFactory {
    
    func populateSongSummary(_ songSummary:inout SongSummary, mediaItem:MPMediaItem) {
        songSummary.artistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.artist as AnyObject?)
        songSummary.title = mediaItem.title!
        songSummary.searchKey = songSummary.title
        songSummary.strippedTitle = MediaObjectUtilities.returnMediaObjectStrippedString(songSummary.title)
        songSummary.indexCharacter = MediaObjectUtilities.returnMediaObjectIndexCharacter(songSummary.strippedTitle)
        songSummary.persistentID = mediaItem.persistentID
        songSummary.lastPlayedTime = 0
    }
    
    func populateSong(_ song:inout Song, songURL:URL, songSummary:SongSummary, mediaItem:MPMediaItem, databaseInterface: DatabaseInterface) {
        song.albumPersistentID = mediaItem.albumPersistentID
        song.assetURL = NSKeyedArchiver.archivedData(withRootObject: songURL)
        song.duration = mediaItem.playbackDuration
        song.albumArtistName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.albumArtist as AnyObject?)
        song.albumTitle = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.albumTitle as AnyObject?)
        song.genreName = MediaObjectUtilities.anyObjectToStringOrEmptyString(mediaItem.genre as AnyObject?)
        song.trackNumber = UInt64(mediaItem.albumTrackNumber)
        songSummary.persistentKey = SongsInterface.persistentKeyForSong(song, songSummary: songSummary, databaseInterface: databaseInterface)
        song.summary = songSummary
    }
    
}
