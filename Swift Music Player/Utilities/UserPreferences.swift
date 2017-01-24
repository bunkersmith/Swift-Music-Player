//
//  UserPreferences.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/25/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class UserPreferences: NSObject {
    
    fileprivate var shuffleFlag:Bool!
    fileprivate var volumeLevel:Float!
    fileprivate(set) var instrumentalAlbums:Array<NSDictionary>!
    
    fileprivate lazy var userDefaults = UserDefaults.standard
    
    override init() {
        super.init()
        loadUserPreferences()
    }
    
    func readDefaultValues()
    {
        if let path = Bundle.main.path(forResource: "DefaultValues", ofType: "plist") {
            if let preferencesDictionary = NSDictionary(contentsOfFile: path) {
                userDefaults.register(defaults: preferencesDictionary as! [String : AnyObject])
                let _ = synchronize()
            }
        }
    }
    
    func loadUserPreferences()
    {
        readDefaultValues()
    
        if let shuffleFlagNumber = userDefaults.value(forKey: "shuffleFlag") as? NSNumber {
            shuffleFlag = shuffleFlagNumber.boolValue
        }
        if let instrumentalAlbumsArray:AnyObject = userDefaults.value(forKey: "instrumentalAlbums") as AnyObject? {
            instrumentalAlbums = instrumentalAlbumsArray as! Array<NSDictionary>
        }
        if let volumeLevelNumber = userDefaults.value(forKey: "volumeLevel") as? NSNumber {
            volumeLevel = volumeLevelNumber.floatValue
        }
    }

    func synchronize() -> Bool {
        let returnValue = userDefaults.synchronize()
        
        if !returnValue {
            Logger.writeToLogFile("NSUserDefaults.synchronize failed")
        }
        
        return returnValue
    }
    
    func volumeLevelValue() -> Float {
        return volumeLevel
    }
    
    func changeVolumeLevel(_ newValue: Float) {
        volumeLevel = newValue

        userDefaults.set(NSNumber(value: volumeLevel as Float), forKey:"volumeLevel")
        
        let _ = synchronize()
    }
    
    func shuffleFlagValue() -> Bool {
        return shuffleFlag
    }
    
    func toggleShuffleFlagSetting() {
        Logger.logDetails(msg:"called with shuffleFlag = \(shuffleFlag)")
        
        shuffleFlag = !shuffleFlag

        userDefaults.set(shuffleFlag, forKey: "shuffleFlag")
        
        Logger.logDetails(msg:"Leaving with shuffleFlag = \(shuffleFlag)")
        
        let _ = synchronize()
    }
    
    func changeShuffleFlagSetting(_ newValue: Bool) {
        Logger.logDetails(msg:"called with newValue = \(newValue)")
        
        shuffleFlag = newValue

        userDefaults.set(shuffleFlag, forKey: "shuffleFlag")
        
        Logger.writeToLogFile("Leaving with shuffleFlag = \(shuffleFlag)")
        
        let _ = synchronize()
    }
}
