//
//  RemoteAudioCommandHandler.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class RemoteAudioCommandHandler: NSObject {
    
    func enableDisableRemoteCommands(enabled: Bool) {
        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        remoteCommandCenter.playCommand.enabled = enabled
        remoteCommandCenter.pauseCommand.enabled = enabled
        remoteCommandCenter.nextTrackCommand.enabled = enabled
        remoteCommandCenter.previousTrackCommand.enabled = enabled
    }
    
    func addRemoteCommandHandlers() {
        // If using a nonmixable audio session category, as this app does, you must activate reception of
        //    remote-control events to allow reactivation of the audio session when running in the background.
        //    Also, to receive remote-control events, the app must be eligible to become the first responder.
        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        remoteCommandCenter.playCommand.addTarget(self, action: #selector(playEventReceived))
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(pauseEventReceived))
        remoteCommandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrackEventReceived))
        remoteCommandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrackEventReceived))
    }
    
    func playEventReceived() {
        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.playAudio", object:self)
    }
    
    func pauseEventReceived() {
        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.pauseAudio", object:self)
    }
    
    func nextTrackEventReceived() {
        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.nextTrack", object: self)
    }
    
    func previousTrackEventReceived() {
        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.previousTrack", object: self)
    }
}