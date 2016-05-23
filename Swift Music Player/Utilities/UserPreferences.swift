//
//  UserPreferences.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/25/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class UserPreferences: NSObject {
    
    private var shuffleFlag:Bool!
    private var volumeLevel:Float!
    private(set) var instrumentalAlbums:Array<NSDictionary>!
    
    override init() {
        super.init()
        loadUserPreferences()
    }
    
    func readDefaultValues()
    {
        if let path = NSBundle.mainBundle().pathForResource("DefaultValues", ofType: "plist") {
            if let preferencesDictionary = NSDictionary(contentsOfFile: path) {
                NSUserDefaults.standardUserDefaults().registerDefaults(preferencesDictionary as! [String : AnyObject])
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    func loadUserPreferences()
    {
        readDefaultValues()
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
    
        if let shuffleFlagNumber = userDefaults.valueForKey("shuffleFlag") as? NSNumber {
            shuffleFlag = shuffleFlagNumber.boolValue
        }
        if let instrumentalAlbumsArray:AnyObject = userDefaults.valueForKey("instrumentalAlbums") {
            instrumentalAlbums = instrumentalAlbumsArray as! Array<NSDictionary>
        }
        if let volumeLevelNumber = userDefaults.valueForKey("volumeLevel") as? NSNumber {
            volumeLevel = volumeLevelNumber.floatValue
        }
    }

    func volumeLevelValue() -> Float {
        return volumeLevel
    }
    
    func changeVolumeLevel(newValue: Float) -> Bool {
        volumeLevel = newValue
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSNumber(float: volumeLevel), forKey:"volumeLevel")
        
        return userDefaults.synchronize()
    }
    
    func shuffleFlagValue() -> Bool {
        return shuffleFlag
    }
    
    func toggleShuffleFlagSetting() -> Bool {
        shuffleFlag = !shuffleFlag
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSNumber(bool: shuffleFlag), forKey:"shuffleFlag")
        
        return userDefaults.synchronize()
    }
    
    func changeShuffleFlagSetting(newValue: Bool) -> Bool {
        shuffleFlag = newValue
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSNumber(bool: shuffleFlag), forKey:"shuffleFlag")
        
        return userDefaults.synchronize()
    }
}
