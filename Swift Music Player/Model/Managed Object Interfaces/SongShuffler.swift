//
//  SongShuffler.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/29/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

let secondsInADay = 3600.0 * 24.0
let secondsInOneWeek = secondsInADay * 7.0
let secondsInTwoWeeks = secondsInADay * 14.0
let secondsInThreeWeeks = secondsInADay * 21.0

class SongShuffler: NSObject {
    
    private var threeWeekOldSongs:[SongPlayRecord]!
    private var twoWeekOldSongs:[SongPlayRecord]!
    private var oneWeekOldSongs:[SongPlayRecord]!
    private var recentSongs:[SongPlayRecord]!
    private var unplayedSongs:[SongPlayRecord]!
    var songListType:String = "Unknown"
    
    init(songList: [SongPlayRecord]) {
        super.init()
        
        let now = DateTimeUtilities.returnNowTimeInterval()
        
        recentSongs = SongShufflerUtilities.returnRecentSongs(songList, now: now)
        recentSongs.shuffle()

        oneWeekOldSongs = SongShufflerUtilities.returnOneWeekOldSongs(songList, now: now)
        oneWeekOldSongs.shuffle()
        
        twoWeekOldSongs = SongShufflerUtilities.returnTwoWeekOldSongs(songList, now: now)
        twoWeekOldSongs.shuffle()
        
        threeWeekOldSongs = SongShufflerUtilities.returnThreeWeekOldSongs(songList, now: now)
        threeWeekOldSongs.shuffle()
        
        unplayedSongs = SongShufflerUtilities.returnUnplayedSongs(songList)
        unplayedSongs.shuffle()
        
        //let playedSongs = SongShufflerUtilities.returnPlayedSongs(songList)
    }
    
    override var description: String {
        var returnValue = "***** SONG SHUFFLER *****"
        returnValue = returnValue + "\nrecentSongs (\(recentSongs.count)):"
        for recentSong in recentSongs {
            returnValue = returnValue + songPlayRecordDescription(recentSong)
        }
        returnValue = returnValue + "\noneWeekOldSongs (\(oneWeekOldSongs.count)):"
        for oneWeekOldSong in oneWeekOldSongs {
            returnValue = returnValue + songPlayRecordDescription(oneWeekOldSong)
        }
        returnValue = returnValue + "\ntwoWeekOldSongs (\(twoWeekOldSongs.count)):"
        for twoWeekOldSong in twoWeekOldSongs {
            returnValue = returnValue + songPlayRecordDescription(twoWeekOldSong)
        }
        returnValue = returnValue + "\nthreeWeekOldSongs (\(threeWeekOldSongs.count)):"
        for threeWeekOldSong in threeWeekOldSongs {
            returnValue = returnValue + songPlayRecordDescription(threeWeekOldSong)
        }
        returnValue = returnValue + "\nunplayedSongs (\(unplayedSongs.count)):"
        for unplayedSong in unplayedSongs {
            returnValue = returnValue + songPlayRecordDescription(unplayedSong)
        }
        return returnValue
    }
    
    func songPlayRecordDescription(songPlayRecord: SongPlayRecord) -> String {
        var returnValue = "\n-----------------------------------"
        returnValue += "\nlastPlayedTime: \(DateTimeUtilities.timeIntervalToString(songPlayRecord.lastPlayedTime))"
        returnValue += "\npersistentID: \(songPlayRecord.persistentKey)"
        returnValue += "\ntitle: \(songPlayRecord.title)"
        
        return returnValue
    }
    
    func skipSongInArray(inout songArray: [SongPlayRecord]) -> Bool {
        if songArray.count > 0 {
            if let songToSkip = songArray.first {
                songArray.removeAtIndex(0)
                songArray.append(songToSkip)
                return true
            }
        }
        return false
    }
    
    func skipShuffleSong() {
        if skipSongInArray(&unplayedSongs!) {
            return
        }
        if skipSongInArray(&threeWeekOldSongs!) {
            return
        }
        if skipSongInArray(&twoWeekOldSongs!) {
            return
        }
        if skipSongInArray(&oneWeekOldSongs!) {
            return
        }
        if skipSongInArray(&recentSongs!) {
            return
        }
    }
    
    func fetchShuffleSong() -> Song {
        return retrieveNewSong(retrieveNewSongPlayRecord())
    }
    
    func findSongPlayRecordIndexForSong(song: Song, songArray: [SongPlayRecord]) -> Int? {
        return songArray.indexOf({$0.persistentKey == song.summary.persistentKey})
    }
    
    func removeAndReturnSongPlayRecord(song: Song, inout songArray:[SongPlayRecord]) -> SongPlayRecord? {
        var returnValue:SongPlayRecord? = nil

        let foundSongIndex = findSongPlayRecordIndexForSong(song, songArray: songArray)

        if foundSongIndex != nil {
            returnValue = songArray[foundSongIndex!]
            songArray.removeAtIndex(foundSongIndex!)
        }
        return returnValue
    }

    func processRecentlyPlayedSong(songPlayRecord: SongPlayRecord, lastPlayedTime: NSTimeInterval){
        songPlayRecord.lastPlayedTime = lastPlayedTime
        recentSongs.append(songPlayRecord)
    }
    
    func moveOldSongToPlayedSongsList(oldSong: Song) {
        Logger.writeToLogFile("In moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count) and oldSong = \(MediaObjectUtilities.titleArtistLastPlayedTimeAndPersistentKeyStringForSong(oldSong))")
        if let oldSongPlayRecord = removeAndReturnSongPlayRecord(oldSong, songArray: &unplayedSongs!) {
            Logger.writeToLogFile("moveOldSongToPlayedSongsList found oldSong \(MediaObjectUtilities.titleArtistLastPlayedTimeAndPersistentKeyStringForSong(oldSong)) in unplayedSongs array")
            processRecentlyPlayedSong(oldSongPlayRecord, lastPlayedTime: oldSong.summary.lastPlayedTime)
            Logger.writeToLogFile("After removal from unplayedSongs and append to recentSongs, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            return
        }
        if let oldSongPlayRecord = removeAndReturnSongPlayRecord(oldSong, songArray: &threeWeekOldSongs!) {
            Logger.writeToLogFile("moveOldSongToPlayedSongsList found oldSong in threeWeekOldSongs array")
            processRecentlyPlayedSong(oldSongPlayRecord, lastPlayedTime: oldSong.summary.lastPlayedTime)
            Logger.writeToLogFile("After removal from threeWeekOldSongs and append to recentSongs, threeWeekOldSongs.count = \(threeWeekOldSongs.count) and recentSongs.count = \(recentSongs.count)")
            Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            return
        }
        if let oldSongPlayRecord = removeAndReturnSongPlayRecord(oldSong, songArray: &twoWeekOldSongs!) {
            Logger.writeToLogFile("moveOldSongToPlayedSongsList found oldSong in twoWeekOldSongs array")
            processRecentlyPlayedSong(oldSongPlayRecord, lastPlayedTime: oldSong.summary.lastPlayedTime)
            Logger.writeToLogFile("After removal from twoWeekOldSongs and append to recentSongs, twoWeekOldSongs.count = \(twoWeekOldSongs.count) and recentSongs.count = \(recentSongs.count)")
            Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            return
        }
        if let oldSongPlayRecord = removeAndReturnSongPlayRecord(oldSong, songArray: &oneWeekOldSongs!) {
            Logger.writeToLogFile("moveOldSongToPlayedSongsList found oldSong in oneWeekOldSongs array")
            processRecentlyPlayedSong(oldSongPlayRecord, lastPlayedTime: oldSong.summary.lastPlayedTime)
            Logger.writeToLogFile("After removal from oneWeekOldSongs and append to recentSongs, oneWeekOldSongs.count = \(oneWeekOldSongs.count) and recentSongs.count = \(recentSongs.count)")
            Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            return
        }
        if let oldSongPlayRecord = removeAndReturnSongPlayRecord(oldSong, songArray: &recentSongs!) {
            Logger.writeToLogFile("moveOldSongToPlayedSongsList found oldSong in recentSongs array")
            processRecentlyPlayedSong(oldSongPlayRecord, lastPlayedTime: oldSong.summary.lastPlayedTime)
            Logger.writeToLogFile("After removal from recentSongs and append to recentSongs, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
            return
        }
        Logger.writeToLogFile("moveOldSongToPlayedSongsList could not find oldSong in recentSongs array")
        Logger.writeToLogFile("Leaving SongShuffler.moveOldSongToPlayedSongsList, unplayedSongs.count = \(unplayedSongs.count) and recentSongs.count = \(recentSongs.count)")
    }
    
    func retrieveSongPlayRecord(songPlayRecArray: [SongPlayRecord]) -> SongPlayRecord? {
        if songPlayRecArray.count > 0 {
            return songPlayRecArray.first
        }
        return nil
    }
    
    func retrieveNewSongPlayRecord() -> SongPlayRecord {
        if let song = retrieveSongPlayRecord(unplayedSongs) {
            Logger.writeToLogFile("retrieveNewSongPlayRecord returning unplayed song \(songPlayRecordDescription(song))")
            return song
        }
        if let song = retrieveSongPlayRecord(threeWeekOldSongs) {
            Logger.writeToLogFile("retrieveNewSongPlayRecord returning three week old song \(songPlayRecordDescription(song))")
            return song
        }
        if let song = retrieveSongPlayRecord(twoWeekOldSongs) {
            Logger.writeToLogFile("retrieveNewSongPlayRecord returning two week old song \(songPlayRecordDescription(song))")
            return song
        }
        if let song = retrieveSongPlayRecord(oneWeekOldSongs) {
            Logger.writeToLogFile("retrieveNewSongPlayRecord returning one week old song \(songPlayRecordDescription(song))")
            return song
        }

        let song = retrieveSongPlayRecord(recentSongs)!
        Logger.writeToLogFile("retrieveNewSongPlayRecord returning recent song titled \(songPlayRecordDescription(song))")
        return song
    }
    
    func retrieveNewSong(songPlayRecord: SongPlayRecord) -> Song {
        let returnValue = SongFetcher.fetchSongBySongPersistentKey(songPlayRecord.persistentKey, databaseInterface: DatabaseInterface(forMainThread: true))!
        Logger.writeToLogFile("retrieveNewSong returning \(MediaObjectUtilities.titleArtistLastPlayedTimeAndPersistentKeyStringForSong(returnValue))")
        return returnValue
    }
}
