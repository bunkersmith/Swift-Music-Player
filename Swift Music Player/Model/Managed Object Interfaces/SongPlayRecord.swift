//
//  SongPlayRecord.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/29/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class SongPlayRecord : NSObject, NSCoding {
    var persistentKey: Int64 = 0
    var lastPlayedTime: NSTimeInterval = 0
    var title: String = ""
    
    override var description: String {
        var returnValue = "\n***** SONG PLAY RECORD *****"
        returnValue = returnValue + "\npersistentKey: \(persistentKey)" // was %llu
        returnValue = returnValue + "\nlastPlayedTime: \(DateTimeUtilities.timeIntervalToString(lastPlayedTime)) (\(lastPlayedTime))"
        returnValue = returnValue + "\ntitle: " + title
        return returnValue
    }
    
    init(persistentKey: Int64, lastPlayedTime: NSTimeInterval, title: String) {
        self.persistentKey = persistentKey
        self.lastPlayedTime = lastPlayedTime
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        persistentKey = aDecoder.decodeInt64ForKey("persistentKey")
        lastPlayedTime = aDecoder.decodeDoubleForKey("lastPlayedTime")
        if let localTitle = aDecoder.decodeObjectForKey("title") as? String {
            title = localTitle
        }
        else {
            title = ""
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt64(persistentKey, forKey: "persistentKey")
        aCoder.encodeDouble(lastPlayedTime, forKey: "lastPlayedTime")
        aCoder.encodeObject(title, forKey: "title")
    }
}

func ==(lhs: SongPlayRecord, rhs: SongPlayRecord) -> Bool
{
    return lhs.persistentKey == rhs.persistentKey
}