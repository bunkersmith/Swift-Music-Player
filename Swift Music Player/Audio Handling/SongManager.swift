//
//  SongManager.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/25/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class SongManager: NSObject, AVAudioPlayerDelegate {

    var song:Song?
    weak var delegate: AVAudioPlayerDelegate?
    
    fileprivate var audioPlayer: AudioPlayer?
    fileprivate var songList: [SongPlayRecord]!
    fileprivate var songShuffler: SongShuffler?
    fileprivate var previousSongs: [NSNumber] = []

    fileprivate var songListType = "Unknown"
    fileprivate var nowPlayingTimer: Timer? = nil

    fileprivate lazy var notificationCenter = NotificationCenter.default

    // Singleton instance
    static let instance = SongManager.loadInstance()
    
    fileprivate class func loadInstance() -> SongManager
    {
        if let songManagerData:SongManager = NSKeyedUnarchiver.unarchiveObject(withFile: FileUtilities.songManagerArchiveFilePath()) as? SongManager {
            return songManagerData
        }
        return SongManager()
    }
    
    fileprivate override init() {
        super.init()
        
        NSLog("\(type(of: self)).\(#function) called with NSThread.isMainThread() = \(Thread.isMainThread)")
        addNotificationObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        guard let songPersistentIDNumber = aDecoder.decodeObject(forKey: "songPersistentID") as? NSNumber else {
            Logger.writeToLogFile("\(type(of: self)).\(#function) songPersistentIDNumber is nil")
            return
        }
        
        let songPersistentID = songPersistentIDNumber.uint64Value
        NSLog("\(type(of: self)).\(#function) songPersistentID = \(songPersistentID)")
        guard let song = SongFetcher.fetchSongWithPersistentID(songPersistentID, databaseInterface: DatabaseInterface()) else {
            return
        }
        
        self.song = song
        NSLog("\(type(of: self)).\(#function) self.song = \(self.song)")
        
        let songListObject = aDecoder.decodeObject(forKey: "songList")
        //NSLog("songListObject = \(songListObject)")
        
        if let songList = songListObject as? [SongPlayRecord] {
            self.songList = songList
        }
        
        let previousSongsObject = aDecoder.decodeObject(forKey: "previousSongs")
        
        if let previousSongs = previousSongsObject as? [NSNumber] {
            self.previousSongs = previousSongs
        } else {
            previousSongs = []
        }
        
        createAudioPlayer()
        createSongShuffler()
        updateUIInfo()

        addNotificationObservers()
        
        let songElapsedTime = aDecoder.decodeDouble(forKey: "songElapsedTime")
        
        audioPlayer?.updateSongTime(songElapsedTime)
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        guard let song = song else {
            NSLog("\(type(of: self)).\(#function) song is nil")
            return
        }
        
        aCoder.encode(NSNumber(value: song.summary.persistentID as UInt64), forKey: "songPersistentID")
        aCoder.encode(songList, forKey: "songList")
        aCoder.encode(previousSongs, forKey: "previousSongs")
        
        guard let audioPlayer = audioPlayer else {
            NSLog("\(type(of: self)).\(#function) audioPlayer is nil")
            return
        }
        
        aCoder.encode(audioPlayer.songElapsedTime(), forKey: "songElapsedTime")
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func removeNotificationObservers() {
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.playAudio"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.nextTrack"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.previousTrack"), object: nil)
    }
    
    func addNotificationObservers() {
        notificationCenter.addObserver(self, selector: #selector(playAudio), name:NSNotification.Name(rawValue: "Swift-Music-Player.playAudio"), object: nil)
        notificationCenter.addObserver(self, selector:#selector(pauseAudio), name:NSNotification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object:nil)
        notificationCenter.addObserver(self, selector: #selector(skipToNextSong), name: NSNotification.Name(rawValue: "Swift-Music-Player.nextTrack"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(goBack), name: NSNotification.Name(rawValue: "Swift-Music-Player.previousTrack"), object: nil)
    }
    
    func archiveData() {
        NSKeyedArchiver.archiveRootObject(self, toFile:FileUtilities.songManagerArchiveFilePath())
    }
    
    func playAudio() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) calling audioPlayer.playAudio()")
        
        audioPlayer.playAudio()
        createNowPlayingTimer()
        
        updateUIInfo()
    }
    
    func pauseAudio() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) calling audioPlayer.pauseAudio()")
        
        audioPlayer.pauseAudio()
        nowPlayingTimer?.invalidate()
        
        archiveData()
        
        updateUIInfo()
    }
    
    func playOrPauseAudio() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let audioWasPlaying = audioPlayer.isAudioPlaying()
        
        audioPlayer.playOrPauseAudio()
        
        audioWasPlaying ? nowPlayingTimer?.invalidate() : createNowPlayingTimer()
    }
    
    func createAudioPlayer() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        guard let song = song else {
            Logger.writeToLogFile("song is nil in \(type(of: self)).\(#function)")
            return
        }
        
        guard let songURL = NSKeyedUnarchiver.unarchiveObject(with: song.assetURL as Data) as? URL else {
            Logger.writeToLogFile("songURL is nil in \(type(of: self)).\(#function)")
            return
        }
        
        audioPlayer = AudioPlayer(url: songURL)
        
        guard let audioPlayer = audioPlayer else {
            Logger.writeToLogFile("Audio player creation failed in \(type(of: self)).\(#function)")
            return
        }
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) created audioPlayer for \(song) with url \(songURL)")
        
        audioPlayer.delegate = self
        Logger.writeToLogFile("Audio player delegate assigned to \(type(of: self)) in \(type(of: self)).\(#function) for \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
    }

    func updateUIInfo() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.refreshNowPlayingInformation"), object:self)
        updateNowPlayingInfoCenter()
    }
    
    func createNowPlayingTimer() {
        nowPlayingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateNowPlayingInfoCenter), userInfo: nil, repeats: true)
    }
    
    func playSong(_ createPlayer: Bool) {
        if createPlayer {
            createAudioPlayer()
        }
        
        playOrPauseAudio()
        updateUIInfo()
    }

    func loadNextSong() {
        let shuffleFlag = UserPreferences().shuffleFlagValue()
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) called with UserPreferences().shuffleFlagValue() = \(shuffleFlag)")
        
        if shuffleFlag {
            loadNextShuffleSong()
        } else {
            if !currentSongIsLastSong() {
                if let songIndex = returnSongListIndexForSong(song) {
                    let nextSongPersistentKey = songList[songIndex + 1].persistentKey
                    song = SongFetcher.fetchSongBySongPersistentKey(nextSongPersistentKey, databaseInterface: DatabaseInterface())
                }
            }
        }
        
        createAudioPlayer()
        updateUIInfo()
    }

    func goBack() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let elapsedTime = audioPlayer.songElapsedTime()
        Logger.writeToLogFile("\(type(of: self)).\(#function) called with elapsedTime = \(elapsedTime)")
        
        if elapsedTime > 1.0 {
            updateSongTime(0.0)
        } else {
            let audioPlaying = audioPlayer.isAudioPlaying()
            Logger.writeToLogFile("audioPlaying = \(audioPlaying)")
            audioPlaying ? playPreviousSong() : loadPreviousSong()
        }
    }
    
    func loadPreviousSong() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        guard let last = previousSongs.last else {
            return
        }
        
        song = SongFetcher.fetchSongBySongPersistentKey(last.int64Value, databaseInterface: DatabaseInterface())

        guard let song = song else {
            return
        }
        
        audioPlayer?.endSong()
        
        previousSongs.removeLast()
        
        archiveData()
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) set song to \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
        
        createAudioPlayer()
        updateUIInfo()
    }
    
    func playPreviousSong() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        loadPreviousSong()
        playSong(false)
        updateUIInfo()
    }
    
    func playNextSong() {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")

        loadNextSong()
        
        guard song != nil else {
            return
        }
        
        playSong(false)
    }

    func currentSongIsLastSong() -> Bool {
        return song?.summary.persistentKey == songList[songList.count - 1].persistentKey
    }
    
    func songElapsedTime() -> TimeInterval {
        guard let audioPlayer = audioPlayer else {
            return 0
        }
        
        return audioPlayer.songElapsedTime()
    }
    
    func isAudioPlaying() -> Bool {
        guard let audioPlayer = audioPlayer else {
            return false
        }
        
        return audioPlayer.isAudioPlaying()
    }
    
    func updateSongTime(_ songTime: TimeInterval) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        audioPlayer.updateSongTime(songTime)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.songTimeUpdated"), object:self)
    }

    func adjustVolume(_ volume: Float) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        audioPlayer.adjustVolume(volume)
    }
    
    func returnSongListIndexForSong(_ song: Song?) -> Int? {
        //Logger.writeToLogFile("\(self.dynamicType).\(#function) called")
        
        guard song != nil else {
            Logger.writeToLogFile("\(type(of: self)).\(#function) found a nil song")
            return nil
        }
        
        //Logger.writeToLogFile("\(self.dynamicType).\(#function) songList.count = \(songList.count)")
        
        let returnValue = songList.index(where: { $0.persistentKey == song!.summary.persistentKey })

        //Logger.writeToLogFile("\(self.dynamicType).\(#function) returning \(returnValue)")

        return returnValue
    }
    
    func returnTrackOfTracksForSong(_ song: Song) -> (trackNumber: Int, totalTracks: Int) {
        guard let songIndex = returnSongListIndexForSong(song) else {
            return (-1, songList.count)
        }
        
        return (songIndex + 1, songList.count)
    }
    
    // Contents of albumTracks: array of NSOrderedSets
    // What songList needs: SongPlayRecords
    
    func fillSongListFromAlbumTracks(_ albumTracks:Array<NSOrderedSet>, containsMultipleAlbums: Bool) {
        previousSongs = []
        songList = []
         
        for albumOrderedSet:NSOrderedSet in albumTracks {
            for (_, object) in albumOrderedSet.enumerated() {
                let song = object as! Song
                songList.append(SongPlayRecord(persistentKey: song.summary.persistentKey, lastPlayedTime: song.summary.lastPlayedTime, title: song.summary.title))
            }
        }
        
        createSongShuffler()
        
        songListType = containsMultipleAlbums ? "Multi-Album Song List" : "Album Songs List"
     }
    
    func fillSongListFromPlaylistSongs(_ playlistPersistentID:UInt64) {
        previousSongs = []
        songList = SongFetcher.fetchPlaylistSongListPersistentKeysAndLastPlayedTimes(playlistPersistentID)
        songListType = "Playlist Songs List"
        
        createSongShuffler()
    }
    
    func fillSongListWithAllSongs() {
        previousSongs = []
        songList = SongFetcher.fetchSongListPersistentKeysAndLastPlayedTimes(nil)
        songListType = "All Songs List"
        
        createSongShuffler()
    }

    func skipToNextSong() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let audioWasPlaying = isAudioPlaying()

        audioPlayer.endSong()
        
        songShuffler?.skipShuffleSong()

        archiveData()
        
        audioWasPlaying ? playNextSong() : loadNextSong()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.refreshNowPlayingInformation"), object:self)
    }

    func createSongShuffler() {
        if UserPreferences().shuffleFlagValue() {
            songShuffler = SongShuffler(songList: songList)
        }
    }
    
    func loadNextShuffleSong() {
        if songShuffler == nil {
            Logger.writeToLogFile("\(type(of: self)).\(#function) called with nil songShuffler")
        }
        
        song = songShuffler?.fetchShuffleSong()
        
        Logger.writeToLogFile("\(type(of: self)).\(#function) returning \(song)")
    }
    
    func shuffleAll() {
        previousSongs = []
        
        createSongShuffler()
        
        loadNextShuffleSong()
    }
    
    func updateNowPlayingInfoCenter() {
        //Logger.writeToLogFile("\(self.dynamicType).\(#function) called")
        
        guard let song = self.song else {
            return
        }
        
        //Logger.writeToLogFile("SongPlayer.updateNowPlayingInfoCenter song = \(song)")
        
        var nowPlayingDict =
            [MPMediaItemPropertyTitle: song.summary.title,
             MPMediaItemPropertyAlbumTitle: song.albumTitle,
             MPMediaItemPropertyAlbumTrackNumber: NSNumber(value: UInt(song.trackNumber) as UInt),
             MPMediaItemPropertyArtist: song.summary.artistName,
             MPMediaItemPropertyPlaybackDuration: song.duration,
             MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Float)] as [String : Any]
        
        if let audioPlayer = audioPlayer {
            nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer.songElapsedTime() as Double)
            //Logger.writeToLogFile("\(self.dynamicType).\(#function) elapsed time = \(nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime])")
        } else {
            Logger.writeToLogFile("\(type(of: self)).\(#function) audioPlayer is nil")
        }
        
        if let songArtwork = song.albumArtwork() {
            nowPlayingDict[MPMediaItemPropertyArtwork] = songArtwork
        } else {
            Logger.writeToLogFile("\(type(of: self)).\(#function) songArtwork is nil")
        }
        
        //NSLog("\(self.dynamicType).\(#function) nowPlayingDict = \(nowPlayingDict)")
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingDict
        
        /*
             Album *album = [song albumFromAlbumPersistentID]
             if (album) {
                 GlobalVars *globalVarsPtr = [GlobalVars sharedGlobalVars]
                 globalVarsPtr.currentAlbum = album.internalID
                 globalVarsPtr.currentSong = song.internalID
             }
         */
    }
    
    // MARK: Audio Player Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            Logger.writeToLogFile("\(type(of: self)).\(#function) called")
            
            self.nowPlayingTimer?.invalidate()
            
            guard let song = self.song else {
                Logger.writeToLogFile("\(type(of: self)).\(#function) found a nil song")
                return
            }

            song.updateLastPlayedTime(DateTimeUtilities.returnNowTimeInterval(), databaseInterface: DatabaseInterface())
                
            self.previousSongs.append(NSNumber(value: song.summary.persistentKey as Int64))
            
            if let songShuffler = self.songShuffler {
                songShuffler.moveOldSongToPlayedSongsList(song)
            } else {
                Logger.writeToLogFile("\(type(of: self)).\(#function) found a nil songShuffler")
            }
            
            Logger.writeToLogFile("\(type(of: self)).\(#function) found a non-nil song")

            self.archiveData()
            
            if let delegate = self.delegate {
                delegate.audioPlayerDidFinishPlaying?(player, successfully: flag)
            } else {
                Logger.writeToLogFile("\(type(of: self)).\(#function) found a nil songShuffler")
            }
            
            self.playNextSong()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Logger.writeToLogFile("\(type(of: self)).\(#function) called")
        
        delegate?.audioPlayerDecodeErrorDidOccur?(player, error: error)
    }
}
