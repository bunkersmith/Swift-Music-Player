//
//  FileUtilities.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class FileUtilities {
   
    class func applicationDocumentsDirectory() -> NSURL {
        // The directory the application uses to store various files.
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    }
    
    class func loggerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.URLByAppendingPathComponent("Swift-Music-Player.loggerArchive").path!
    }
    
    class func logFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.URLByAppendingPathComponent("Swift-Music-PlayerLog.txt").path!
    }
    
    class func playedSongsFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.URLByAppendingPathComponent("Swift-Music-PlayerPlayedSongs.txt").path!
    }
    
    class func songPlayerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.URLByAppendingPathComponent("Swift-Music-Player.songPlayerArchive").path!
    }
    
    class func npPersistentDataArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.URLByAppendingPathComponent("Swift-Music-Player.npPersistentDataArchive").path!
    }
    
    class func returnPlayedSongsFileAsNSData() -> NSData? {
        let playedSongsFilePath = FileUtilities.playedSongsFilePath()
        return NSData(contentsOfFile: playedSongsFilePath)
    }
}
