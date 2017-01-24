//
//  NowPlayingViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation

class NowPlayingViewController: PortraitViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var songTitleLabel: MarqueeLabel!
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var albumTitleLabel: MarqueeLabel!
    @IBOutlet weak var trackOfTracksLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var trackTimeElapsedLabel: UILabel!
    @IBOutlet weak var trackTimeRemainingLabel: UILabel!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!

    //var song: Song?
    var songNeedsPlaying = false
    
    fileprivate var pauseIconImage:UIImage = UIImage(named: "pause-icon.png")!
    fileprivate var playIconImage:UIImage = UIImage(named: "play-icon.png")!
    fileprivate var displayLink:CADisplayLink?
    fileprivate var songManager = SongManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressSlider.configureSlider("min-progress-slider.png", maxTrackImageName: "max-progress-slider.png", thumbImageName: "now-playing-progress-thumb.png")
        volumeSlider.configureSlider("min-volume-slider.png", maxTrackImageName: "max-volume-slider.png", thumbImageName: "now-playing-volume-thumb.png")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Logger.logDetails(msg: "Entered")
        
        guard songManager.song != nil else {
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserInterface), name: NSNotification.Name(rawValue: "Swift-Music-Player.refreshNowPlayingInformation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSongTimeUpdated), name: NSNotification.Name(rawValue: "Swift-Music-Player.songTimeUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoverFlowViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        songManager.delegate = self
        
        if songNeedsPlaying {
            songNeedsPlaying = false
            songManager.playSong(true)
        }
        
        refreshUserInterface()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Logger.logDetails(msg: "Entered")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.refreshNowPlayingInformation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.songTimeUpdated"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        songManager.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshUserInterface() {
        populateUserInterface()
        
        let isAudioPlaying = songManager.isAudioPlaying()
        
        Logger.logDetails(msg:"Called with isAudioPlaying = \(isAudioPlaying)")
        
        startOrStopPlaybackTimer(isAudioPlaying)
        updatePlayPauseButton(isAudioPlaying)
        updateVolumeSliderDisplay(UserPreferences().volumeLevelValue())
    }

    func handleUpdatePlayPauseButton(_ notification: Notification) {
        DispatchQueue.main.async(execute: { () -> Void in
            if let userInfo:[AnyHashable: Any] = (notification as NSNotification).userInfo {
                if let isPlayingNumber:NSNumber = userInfo["isPlaying"] as? NSNumber {
                    self.updatePlayPauseButton(isPlayingNumber.boolValue)
                }
            }
        })
    }
    
    func populateUserInterface() {
        guard let song = songManager.song else {
            return
        }
        
        configureShuffleButton(UserPreferences().shuffleFlagValue())
        
        songTitleLabel.configureMarqueeLabel(song.summary.title)
        artistNameLabel.configureMarqueeLabel(song.summary.artistName)
        albumTitleLabel.configureMarqueeLabel(song.albumTitle)
        trackTimeRemainingLabel.text = "-\(DateTimeUtilities.durationToMinutesAndSecondsString(song.duration))"
        albumArtworkImageView.image = AlbumsInterface.artworkForAlbum(song.album, size: albumArtworkImageView.bounds.size)
        populateAlbumTrackNumber()
        updatePlaybackElements()
    }
    
    func populateAlbumTrackNumber() {
        guard let song = songManager.song else {
            return
        }
        
        let trackOfTracks = songManager.returnTrackOfTracksForSong(song)
        
        trackOfTracksLabel.text = "\(trackOfTracks.trackNumber) of \(trackOfTracks.totalTracks)"
    }
    
    func updatePlayPauseButton(_ isAudioPlaying: Bool) {
        if isAudioPlaying {
            self.playPauseButton.setImage(pauseIconImage, for: UIControlState())
        }
        else {
            self.playPauseButton.setImage(playIconImage, for: UIControlState())
        }
    }
    
    func startOrStopPlaybackTimer(_ audioIsPlaying: Bool) {
        if audioIsPlaying {
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackElements))
            }
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        } else {
            displayLink?.invalidate()
            displayLink = nil
            //displayLink?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        }
    }
    
    func handleSongTimeUpdated() {
        updatePlaybackElements() 
    }
    
    func updatePlaybackElements() {
        guard let song = songManager.song else {
            return
        }
        
        let songElapsedTime = songManager.songElapsedTime()
        trackTimeElapsedLabel.text = "\(DateTimeUtilities.durationToMinutesAndSecondsString(songElapsedTime))"
        let remainingTime = song.duration - songElapsedTime
        trackTimeRemainingLabel.text = "-\(DateTimeUtilities.durationToMinutesAndSecondsString(remainingTime))"
        progressSlider.setValue(Float(songElapsedTime / song.duration), animated: true)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: AnyObject) {
        playOrPauseAudio()
    }
    
    func playOrPauseAudio() {
        songManager.playOrPauseAudio()
        let audioIsPlaying = songManager.isAudioPlaying()
        updatePlayPauseButton(audioIsPlaying)
        startOrStopPlaybackTimer(audioIsPlaying)
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        songManager.skipToNextSong()
        
        Logger.logDetails(msg:"songManager.song = \(songManager.song)")
    }
    
    @IBAction func previousButtonPressed(_ sender: AnyObject) {
        //Logger.logDetails(msg: "Entered")
        songManager.goBack()
        
        Logger.logDetails(msg:"songManager.song = \(songManager.song)")
    }
    
    @IBAction func shuffleButtonPressed(_ sender: AnyObject) {
        let userPreferences = UserPreferences()
        userPreferences.toggleShuffleFlagSetting()
        
        let shuffleFlagSetting = userPreferences.shuffleFlagValue()
        configureShuffleButton(shuffleFlagSetting)
        
        if shuffleFlagSetting {
            songManager.createSongShuffler()
        }
    }
    
    func configureShuffleButton(_ shuffleValue: Bool) {
        shuffleButton.tintColor = shuffleValue ? UIColor.orange : UIColor.white
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        guard let song = songManager.song else {
            return
        }
        
        var progressSliderValue = progressSlider.value
        if progressSliderValue == 1.0 {
            progressSliderValue = 0.0
        }
        
        let updatedSongTime = TimeInterval(progressSliderValue) * song.duration
        
        Logger.writeToLogFile("Calling songManager.updateSongTime(\(updatedSongTime))")
        
        songManager.updateSongTime(updatedSongTime)
        updatePlaybackElements()
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: UISlider) {
        songManager.adjustVolume(volumeSlider.value)
        UserPreferences().changeVolumeLevel(volumeSlider.value)
    }
    
    func updateVolumeSliderDisplay(_ volumeSliderValue: Float) {
        volumeSlider.value = volumeSliderValue
    }
    
    // MARK: Audio Player Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Logger.logDetails(msg: "Entered")
        updatePlayPauseButton(false)
        startOrStopPlaybackTimer(false)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer,
                                        error: Error?) {
        Logger.logDetails(msg: "Entered")
    }
}
