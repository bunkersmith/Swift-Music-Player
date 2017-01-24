//
//  AudioSessionManager.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/25/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioSessionManager: NSObject {
    fileprivate var audioSessionPtr = AVAudioSession.sharedInstance()
    fileprivate var remoteAudioCommandHandler = RemoteAudioCommandHandler.instance
    fileprivate var audioNotificationHandler = AudioNotificationHandler.instance
    
    // Singleton instance
    static let instance = AudioSessionManager()
    
    fileprivate override init() {
        super.init()
    }
    
    deinit {
        Logger.logDetails(msg: "Calling deactivateAudioSession")
        
        deactivateAudioSession()
    }
    
    func activateAudioSession()
    {
        Logger.logDetails(msg: "Entered")
        
        do {
            try audioSessionPtr.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            Logger.writeToLogFile("Error setting audio session category: \(error)")
        }

        do {
            try audioSessionPtr.setActive(true)
        } catch let error as NSError {
            Logger.writeToLogFile("Error setting audio session to active: \(error)")
        }
    
        audioNotificationHandler.addNotificationObservers()
        remoteAudioCommandHandler.enableDisableRemoteCommands(true)
    }
    
    func deactivateAudioSession() {
        Logger.logDetails(msg: "Entered")
        
        do {
            try audioSessionPtr.setActive(false)
        } catch let error as NSError {
            Logger.writeToLogFile("Error deactivating audio session: \(error)")
        }

        audioNotificationHandler.removeNotificationObservers()
        remoteAudioCommandHandler.enableDisableRemoteCommands(false)
    }
    
}
