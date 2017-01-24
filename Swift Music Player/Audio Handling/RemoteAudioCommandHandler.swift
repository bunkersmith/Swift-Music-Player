//
//  RemoteAudioCommandHandler.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class RemoteAudioCommandHandler: NSObject {
    
    // Singleton instance
    static let instance = RemoteAudioCommandHandler()
    
    fileprivate override init() {
        super.init()
        
        addRemoteCommandHandlers()
    }
    
    lazy var remoteCommandCenter = MPRemoteCommandCenter.shared()

    func enableDisableRemoteCommands(_ enabled: Bool) {
        Logger.logDetails(msg:"Called with enabled = \(enabled)")
        
        remoteCommandCenter.playCommand.isEnabled = enabled
        remoteCommandCenter.pauseCommand.isEnabled = enabled
        remoteCommandCenter.nextTrackCommand.isEnabled = enabled
        remoteCommandCenter.previousTrackCommand.isEnabled = enabled
    }
    
    fileprivate func addRemoteCommandHandlers() {
        Logger.logDetails(msg: "Entered")
        
        // If using a nonmixable audio session category, as this app does, you must activate reception of
        //    remote-control events to allow reactivation of the audio session when running in the background.
        //    Also, to receive remote-control events, the app must be eligible to become the first responder.
        remoteCommandCenter.playCommand.addTarget(self, action: #selector(playEventReceived))
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(pauseEventReceived))
        remoteCommandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrackEventReceived))
        remoteCommandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrackEventReceived))
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func playEventReceived() {
        Logger.logDetails(msg: "Entered")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.playAudio"), object:self)
    }
    
    func pauseEventReceived() {
        Logger.logDetails(msg: "Entered")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object:self)
    }
    
    func nextTrackEventReceived() {
        Logger.logDetails(msg: "Entered")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.nextTrack"), object: self)
    }
    
    func previousTrackEventReceived() {
        Logger.logDetails(msg: "Entered")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.previousTrack"), object: self)
    }
}
