//
//  SongShufflerUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/25/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class SongShufflerUtilities: NSObject {

    class func returnRecentSongs(_ songList: [SongPlayRecord], now: TimeInterval) -> [SongPlayRecord] {
        let recentSongs = songList.filter({
            return now - $0.lastPlayedTime < secondsInOneWeek
        })
        return recentSongs
    }
    
    class func returnOneWeekOldSongs(_ songList: [SongPlayRecord], now: TimeInterval) -> [SongPlayRecord] {
        let oneWeekOldSongs = songList.filter({
            return (now - $0.lastPlayedTime >= secondsInOneWeek) && (now - $0.lastPlayedTime < secondsInTwoWeeks)
        })
        return oneWeekOldSongs
    }
    
    class func returnTwoWeekOldSongs(_ songList: [SongPlayRecord], now: TimeInterval) -> [SongPlayRecord] {
        let twoWeekOldSongs = songList.filter({
            return (now - $0.lastPlayedTime >= secondsInTwoWeeks) && (now - $0.lastPlayedTime < secondsInThreeWeeks)
        })
        return twoWeekOldSongs
    }
    
    class func returnThreeWeekOldSongs(_ songList: [SongPlayRecord], now: TimeInterval) -> [SongPlayRecord] {
        let threeWeekOldSongs = songList.filter({
            return now - $0.lastPlayedTime >= secondsInThreeWeeks
        })
        return threeWeekOldSongs
    }
    
    class func returnPlayedSongs(_ songList: [SongPlayRecord]) -> [SongPlayRecord] {
        let playedSongs = songList.filter({ $0.lastPlayedTime != 0 })
        return playedSongs
    }
    
    class func returnUnplayedSongs(_ songList: [SongPlayRecord]) -> [SongPlayRecord] {
        let unplayedSongs = songList.filter({ $0.lastPlayedTime == 0 })
        return unplayedSongs
    }
    
}
