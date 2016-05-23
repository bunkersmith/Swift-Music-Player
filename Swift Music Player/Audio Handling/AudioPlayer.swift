//
//  AudioPlayer.swift
//  Audio Player Tutorial
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private var audioSessionManager = AudioSessionManager()
    private var audioPlayer: AVAudioPlayer?
    
    init?(url: NSURL) {
        super.init()
        do {
            audioSessionManager.activateAudioSession()
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            addNotificationObservers()
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch let err as NSError {
            print("audioPlayer error \(err.localizedDescription)")
            return nil
        }
    }

    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(playAudio), name:"Swift-Music-Player.playAudio", object: nil)
        notificationCenter.addObserver(self, selector:#selector(pauseAudio), name:"Swift-Music-Player.pauseAudio", object:nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Swift-Music-Player.playAudio", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Swift-Music-Player.pauseAudio", object: nil)
    }
    
    func playAudio() {
        if let player = audioPlayer {
            player.play()
        }
    }
    
    func stopAudio() {
        if let player = audioPlayer {
            player.stop()
        }
    }
    
    func pauseAudio() {
        if let player = audioPlayer {
            player.pause()
        }
    }
    
    func playOrPauseAudio() {
        if let player = audioPlayer {
            if player.playing {
                pauseAudio()
            } else {
                playAudio()
            }
        }
    }
    
    func adjustVolume(volume: Float) {
        if let player = audioPlayer {
            player.volume = volume
        }
    }
    
    func isAudioPlaying() -> Bool {
        if let player = audioPlayer {
            return player.playing
        }
        return false
    }
    
    // MARK: Audio Player Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully
        flag: Bool) {
        NSLog("\(#function) called")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer,
                                        error: NSError?) {
        NSLog("\(#function) called")
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        NSLog("\(#function) called")
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        NSLog("\(#function) called")
    }
}