//
//  Logger.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class Logger: NSObject, NSCoding {
    // This class method initializes the static singleton pointer
    // if necessary, and returns the singleton pointer to the caller
    class var instance: Logger {
        struct Singleton {
            static var instance:Logger? = nil
            static var loggerToken: dispatch_once_t = 0
        }
        dispatch_once(&Singleton.loggerToken) {
            Singleton.instance = self.loadInstance()
        }
        return Singleton.instance!
    }
    
    lazy private var logMessages:[String] = [String]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.logMessages = aDecoder.decodeObjectForKey("logMessages") as! [String]
    }
 
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.logMessages, forKey:"logMessages")
    }
    
    func archiveData() {
        NSKeyedArchiver.archiveRootObject(self, toFile:FileUtilities.loggerArchiveFilePath())
    }
    
    class func loadInstance() -> Logger
    {
        if let loggerData:Logger = NSKeyedUnarchiver.unarchiveObjectWithFile(FileUtilities.loggerArchiveFilePath()) as? Logger {
            return loggerData
        }
        return Logger()
    }
    
    class func writeToLogFile(string: String) {
        Logger.commonMemoryLogger(string, withTimeStamp:true)
    }
    
    class func writeToLogFileSpecial(string: String) {
        Logger.commonMemoryLogger(string, withTimeStamp:true)
    }
    
    class func commonMemoryLogger(stringToWrite: String, withTimeStamp: Bool) {
        NSLog(stringToWrite)
    
        var logString = ""
    
        if withTimeStamp {
            logString = logString + DateTimeUtilities.dateToString(NSDate()) + ": "
        }
    
        logString = logString + stringToWrite
        Logger.instance.logMessages.append(logString)
    }
    
    class func commonDiskLogger(stringToWrite: String, withTimeStamp: Bool) {
        NSLog(stringToWrite)
    
        let logFilePath = FileUtilities.logFilePath()
        var error:NSError?
        var contents = ""
        
        do {
            let oldContents = try String(contentsOfFile: logFilePath, encoding: NSUTF8StringEncoding)
            contents = oldContents + "\n"
        } catch let error1 as NSError {
            error = error1
            // Assume that we're writing to the file for the first time
            NSLog(logFilePath)
        }
    
    
        if withTimeStamp {
            contents = contents + DateTimeUtilities.dateToString(NSDate()) + ": "
        }
    
        contents = contents + stringToWrite
    
        do {
            try contents.writeToFile(logFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            if error != nil {
                NSLog("Error writing to log file (\(logFilePath)): \(error!)")
            }
            else {
                NSLog("Unspedified error writing to log file (\(logFilePath))")
            }
        }
    }
    
    class func writeSeparatorToLogFile() {
    Logger.commonMemoryLogger("#################################################################################################################################################", withTimeStamp:false)
    }
    
    class func writeLogFileToDisk() {
        let logFilePath = FileUtilities.logFilePath()
    
        let fileManager = NSFileManager.defaultManager()
    
        var error:NSError?
    
        if fileManager.fileExistsAtPath(logFilePath) {
            do {
                try fileManager.removeItemAtPath(logFilePath)
            } catch let error1 as NSError {
                error = error1
                if error != nil {
                    NSLog("Error deleting log file (at path \(logFilePath)): \(error!)")
                }
                else {
                    NSLog("Unspedified error deleting log file (at path \(logFilePath))")
                }
            }
        }
    
        let joiner = "\n"
        let joinedStrings = Logger.instance.logMessages.joinWithSeparator(joiner)

        do {
            try joinedStrings.writeToFile(logFilePath, atomically:true, encoding:NSUTF8StringEncoding)
            Logger.instance.logMessages.removeAll(keepCapacity: false)
        } catch let error1 as NSError {
            error = error1
            if error != nil {
                NSLog("Error writing to log file (at path \(logFilePath)): \(error!)")
            }
            else {
                NSLog("Unspecified error writing to log file (at path \(logFilePath))")
            }
        }
    }
    
    class func returnLogFileAsNSData() -> NSData? {
        let logFilePath = FileUtilities.logFilePath()
        return NSData(contentsOfFile: logFilePath)
    }

}
