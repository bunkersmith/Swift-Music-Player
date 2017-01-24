    //
//  AudioPlayer.swift
//  Audio Player Tutorial
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import AVFoundation

class AudioPlayer: NSObject {
    
    weak var delegate: AVAudioPlayerDelegate? {
        didSet {
            audioPlayer?.delegate = delegate
        }
    }
    
    fileprivate var audioSessionManager = AudioSessionManager.instance
    fileprivate var audioPlayer: AVAudioPlayer?
    
    init?(url: URL) {
        super.init()
        
        Logger.logDetails(msg: "Entered")
        
        do {
            audioSessionManager.activateAudioSession()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            //addNotificationObservers()
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = UserPreferences().volumeLevelValue()
        } catch let err as NSError {
            print("audioPlayer error \(err.localizedDescription)")
            return nil
        }
    }

    deinit {
        Logger.logDetails(msg: "Entered")
        
        audioPlayer?.stop()

        //Logger.logDetails(msg: "Calling deactivateAudioSession")
        
        //audioSessionManager.deactivateAudioSession()
    }
    
    func playAudio() {
        Logger.logDetails(msg: "Entered")

        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }
        
        Logger.logDetails(msg: "player.currentTime = \(player.currentTime)")
        
        player.play()
    }
    
    func stopAudio() {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }

        player.stop()
    }
    
    func pauseAudio() {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }

        player.pause()
    }
    
    func playOrPauseAudio() {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }

        Logger.logDetails(msg: "player.currentTime = \(player.currentTime)")
        
        player.isPlaying ? pauseAudio() : playAudio()
    }
    
    func adjustVolume(_ volume: Float) {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }

        player.volume = volume
    }
    
    func isAudioPlaying() -> Bool {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return false
        }

        return player.isPlaying
    }
    
    func updateSongTime(_ time: TimeInterval) {
        Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return
        }

        player.currentTime = time
        
        Logger.logDetails(msg: "Set player.currentTime to \(player.currentTime)")
    }
    
    func songElapsedTime() -> TimeInterval {
        //Logger.logDetails(msg: "Entered")
        
        guard let player = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            
            return 0
        }

        return player.currentTime
    }
    
    func endSong() {
        Logger.logDetails(msg: "Entered")
        
        if isAudioPlaying() {
            stopAudio()
        }
        
        //audioSessionManager.deactivateAudioSession()
    }
    
}
