//
//  AudioSessionManager.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/25/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioSessionManager: NSObject {
    private var sessionIsActive:Bool = false
    private var audioSessionPtr = AVAudioSession.sharedInstance()
    private var remoteAudioCommandHandler = RemoteAudioCommandHandler()
    private var audioNotificationHandler = AudioNotificationHandler()
    
    override init() {
        super.init()
    }
    
    deinit {
        deactivateAudioSession()
    }
    
    func reactivateAudioSession() {
        if !sessionIsActive {
            activateAudioSession()
        }
    }
    
    func activateAudioSession()
    {
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
        remoteAudioCommandHandler.addRemoteCommandHandlers()
        remoteAudioCommandHandler.enableDisableRemoteCommands(true)
        sessionIsActive = true
    }
    
    func deactivateAudioSession() {
        do {
            try audioSessionPtr.setActive(false)
        } catch let error as NSError {
            Logger.writeToLogFile("Error deactivating audio session: \(error)")
        }

        audioNotificationHandler.removeNotificationObservers()
        remoteAudioCommandHandler.enableDisableRemoteCommands(false)
        sessionIsActive = false
    }
    
}
