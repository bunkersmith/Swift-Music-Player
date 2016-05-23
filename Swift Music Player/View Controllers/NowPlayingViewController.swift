//
//  NowPlayingViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController, DatabaseProgressDelegate {

    @IBOutlet weak var songTitleLabel: MarqueeLabel!
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var albumTitleLabel: MarqueeLabel!
    @IBOutlet weak var trackOfTracksLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var trackTimeElapesdLabel: UILabel!
    @IBOutlet weak var trackTimeRemainingLabel: UILabel!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!

    var song: Song!
    
    private var audioPlayer: AudioPlayer?
    private var pauseIconImage:UIImage? = UIImage(named: "pause-icon.png")
    private var playIconImage:UIImage? = UIImage(named: "play-icon.png")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressSlider.configureSlider("min-progress-slider.png", maxTrackImageName: "max-progress-slider.png", thumbImageName: "now-playing-progress-thumb.png")
        volumeSlider.configureSlider("min-volume-slider.png", maxTrackImageName: "max-volume-slider.png", thumbImageName: "now-playing-volume-thumb.png")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        createSongObjects { 
            self.createAlbumObjects({
                dispatch_async(dispatch_get_main_queue(), { 
                    self.song = SongFetcher.fetchSongByTitleArtistAndAlbum("Lonely Boy (LP Version)", artistName: "Andrew Gold", albumTitle: "Thank You For Being a Friend: The Best Of Andrew Gold.")
                    self.populateUserInterface()
                    if let songURL = NSKeyedUnarchiver.unarchiveObjectWithData(self.song.assetURL) as? NSURL {
                        self.audioPlayer = AudioPlayer(url: songURL)
                        if self.audioPlayer == nil {
                            Logger.writeToLogFile("Audio player creation failed in \(#function)")
                        }
                    }
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func progressUpdate(progressFraction:Float, operationType:DatabaseOperationType) {
        let operationTypeString = DatabaseProgress.databaseOperationTypeToString(operationType)
        let progressPercentage = progressFraction * 100.0
        
        NSLog("\(operationTypeString) progress: \(progressPercentage.string(1, maxFractionDigits: 1))")
    }

    func createSongObjects(completionHandler: (() -> ())?) {
        let databaseInterface = DatabaseInterface(forMainThread: NSThread.isMainThread())
        if databaseInterface.countOfEntitiesOfType("Song", predicate: nil) == 0 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let songFactory = SongFactory()
                songFactory.delegate = self
                songFactory.fillDatabaseSongsFromItunesLibrary()
                completionHandler?()
            })
        } else {
            completionHandler?()
        }
    }
    
    func createAlbumObjects(completionHandler: (() -> ())?) {
        let databaseInterface = DatabaseInterface(forMainThread: NSThread.isMainThread())
        if databaseInterface.countOfEntitiesOfType("Album", predicate: nil) == 0 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let albumFactory = AlbumFactory()
                albumFactory.delegate = self
                albumFactory.fillDatabaseAlbumsFromItunesLibrary()
                completionHandler?()
            })
        } else {
            completionHandler?()
        }
    }
    
    func populateUserInterface() {
        songTitleLabel.configureMarqueeLabel(song.summary.title)
        artistNameLabel.configureMarqueeLabel(song.summary.artistName)
        albumTitleLabel.configureMarqueeLabel(song.albumTitle)
        trackTimeRemainingLabel.text = "-\(DateTimeUtilities.durationToMinutesAndSecondsString(song.duration))"
        populateAlbumArtworkImageView()
        populateAlbumTrackNumber()
    }
    
    func populateAlbumArtworkImageView() {
        if let albumArtwork = song.album?.albumArtwork(DatabaseInterface(forMainThread: true)) {
            if let albumArtworkImage = albumArtwork.imageWithSize(albumArtwork.bounds.size) {
                let scaledAlbumArtworkImage = albumArtworkImage.scaleToSize(albumArtworkImageView.bounds.size)
                albumArtworkImageView.image = scaledAlbumArtworkImage
            }
        }
        else {
            albumArtworkImageView.image = UIImage(named: "no-album-artwork.png")!
        }
    }
    
    func populateAlbumTrackNumber() {
        if let album = song.album {
            trackOfTracksLabel.text = "\(song.trackNumber) of \(album.songs.count)"
        }
    }
    
    func updatePlayPauseButton(isAudioPlaying: Bool) {
        if isAudioPlaying {
            if pauseIconImage != nil {
                self.playPauseButton.setImage(pauseIconImage, forState: .Normal)
            }
        }
        else {
            if playIconImage != nil {
                self.playPauseButton.setImage(playIconImage, forState: .Normal)
            }
        }
        //self.startStopSongTimer(isAudioPlaying)
    }
    
    @IBAction func playPauseButtonPressed(sender: AnyObject) {
        //NSLog("\(#function) called")
        if let player = audioPlayer {
            player.playOrPauseAudio()
            updatePlayPauseButton(player.isAudioPlaying())
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        //NSLog("\(#function) called")
    }
    
    @IBAction func previousButtonPressed(sender: AnyObject) {
        //NSLog("\(#function) called")
    }
    
    @IBAction func shuffleButtonPressed(sender: AnyObject) {
        //NSLog("\(#function) called")
    }
    
    @IBAction func progressSliderValueChanged(sender: UISlider) {
        //NSLog("\(#function) called")
        var progressSliderValue = progressSlider.value
        if progressSliderValue == 1.0 {
            progressSliderValue = 0.0
        }
    }
    
    @IBAction func volumeSliderValueChanged(sender: UISlider) {
        //NSLog("\(#function) called")
    }
}
