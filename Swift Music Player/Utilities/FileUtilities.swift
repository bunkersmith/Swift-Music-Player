//
//  FileUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class FileUtilities {
   
    class func applicationDocumentsDirectory() -> URL {
        // The directory the application uses to store various files.
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    class func loggerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player.loggerArchive").path
    }
    
    class func logFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player-Log.txt").path
    }
    
    class func timeStampedLogFileName() -> String {
        let fileNameString = "Swift-Music-Player-Log-\(DateTimeUtilities.currentTimeToString()).txt"
        return fileNameString
    }
    
    class func playedSongsFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player-PlayedSongs.txt").path
    }
    
    class func iCloudPlayedSongsFileName() -> String {
        return "Swift-Music-Player-iCloudPlayedSongs.txt"
    }
    
    class func songManagerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player.songManagerArchive").path
    }
    
    class func songPlayerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player.songPlayerArchive").path
    }
    
    class func npPersistentDataArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("Swift-Music-Player.npPersistentDataArchive").path
    }
    
    class func returnPlayedSongsFileAsNSData() -> Data? {
        let playedSongsFilePath = FileUtilities.playedSongsFilePath()
        return (try? Data(contentsOf: URL(fileURLWithPath: playedSongsFilePath)))
    }
}
