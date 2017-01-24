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

    fileprivate var archivedElapsedTime:TimeInterval = 0
    
    // Singleton instance
    static var instance = SongManager.loadInstance()
    
    fileprivate class func loadInstance() -> SongManager
    {
        Logger.logDetails(msg: "Entered")
        
        /*
            if let songManagerData:SongManager = NSKeyedUnarchiver.unarchiveObject(withFile: FileUtilities.songManagerArchiveFilePath()) as? SongManager {
                return songManagerData
            }
            return SongManager()
        */
        
        let archiveFileUrl = URL(fileURLWithPath:FileUtilities.songManagerArchiveFilePath())
        
        let fileExists = (try? archiveFileUrl.checkResourceIsReachable()) ?? false
        Logger.writeToLogFile("archiveFileUrl = \(archiveFileUrl), exists = \(fileExists)")
        
        // This guard is failing into the else condition
        
        guard let dat = NSData(contentsOf: archiveFileUrl) else {
            Logger.logDetails(msg: "No NSData, returning empty SongManager")
            return SongManager()
        }
        
        do {
            let decodedDataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dat)
            guard let songManager = decodedDataObject as? SongManager else {
                Logger.logDetails(msg: "Could not decode NSData, returning empty SongManager")
                return SongManager()
            }
            return songManager
        }
        catch let error as NSError {
            Logger.logDetails(msg: "Returning empty SongManager after NSKeyedUnarchiver error \(error)")
            return SongManager()
        }
    }
    
    fileprivate override init() {
        super.init()
        
        //Logger.logDetails(msg:"called with NSThread.isMainThread() = \(Thread.isMainThread)")
        addNotificationObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()

        Logger.logDetails(msg: "Entered")
        
        guard let songPersistentIDNumber = aDecoder.decodeObject(forKey: "songPersistentID") as? NSNumber else {
            Logger.logDetails(msg:"songPersistentIDNumber is nil")
            return
        }
        
        let songPersistentID = songPersistentIDNumber.uint64Value
        Logger.logDetails(msg:"songPersistentID = \(songPersistentID)")
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        guard let song = SongFetcher.fetchSongWithPersistentID(songPersistentID, databaseInterface: databaseInterface) else {
            Logger.logDetails(msg:"fetchSongWithPersistentID is nil")
            return
        }
        
        self.song = song
        Logger.logDetails(msg:"self.song = \(self.song)")
        
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
        Logger.logDetails(msg:"songElapsedTime = \(songElapsedTime)")
        
        Logger.writeToLogFile("Calling updateSongTime(\(songElapsedTime))")
        
        updateSongTime(songElapsedTime)
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        guard let song = song else {
            Logger.logDetails(msg:"song is nil")
            return
        }
        
        aCoder.encode(NSNumber(value: song.summary.persistentID as UInt64), forKey: "songPersistentID")
        aCoder.encode(songList, forKey: "songList")
        aCoder.encode(previousSongs, forKey: "previousSongs")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg:"audioPlayer is nil")
            return
        }
        
        let songElapsedTime = audioPlayer.songElapsedTime()
        Logger.logDetails(msg:"songElapsedTime = \(songElapsedTime)")

        aCoder.encode(songElapsedTime, forKey: "songElapsedTime")
        
        archivedElapsedTime = songElapsedTime
        Logger.logDetails(msg:"archivedElapsedTime = \(archivedElapsedTime)")
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func removeNotificationObservers() {
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.playAudio"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.audioPaused"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.nextTrack"), object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.previousTrack"), object: nil)
    }
    
    func addNotificationObservers() {
        notificationCenter.addObserver(self, selector: #selector(playAudio), name:NSNotification.Name(rawValue: "Swift-Music-Player.playAudio"), object: nil)
        notificationCenter.addObserver(self, selector:#selector(pauseAudio), name:NSNotification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object:nil)
        notificationCenter.addObserver(self, selector:#selector(handleAudioPaused), name:NSNotification.Name(rawValue: "Swift-Music-Player.audioPaused"), object:nil)
        notificationCenter.addObserver(self, selector: #selector(skipToNextSong), name: NSNotification.Name(rawValue: "Swift-Music-Player.nextTrack"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(goBack), name: NSNotification.Name(rawValue: "Swift-Music-Player.previousTrack"), object: nil)
    }
    
    func archiveData() {
        let archiveStatus = NSKeyedArchiver.archiveRootObject(self, toFile:FileUtilities.songManagerArchiveFilePath())
        Logger.logDetails(msg:"archiveStatus = \(archiveStatus)")
        
        let fileExists = FileManager.default.fileExists(atPath: FileUtilities.songManagerArchiveFilePath())
        Logger.writeToLogFile("FileUtilities.songManagerArchiveFilePath() = \(FileUtilities.songManagerArchiveFilePath()), exists = \(fileExists)")
    }
    
    func playAudio() {
        Logger.logDetails(msg: "Entered")
        
        if audioPlayer == nil {
            createAudioPlayer()
            audioPlayer?.updateSongTime(archivedElapsedTime)
        }
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        Logger.logDetails(msg:"calling audioPlayer.playAudio() with songElapsedTime = \(audioPlayer.songElapsedTime())")
        
        audioPlayer.playAudio()
        createNowPlayingTimer()
        
        updateUIInfo()
    }
    
    func pauseAudio() {
        Logger.logDetails(msg: "Entered")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        Logger.logDetails(msg:"calling audioPlayer.pauseAudio() with songElapsedTime = \(audioPlayer.songElapsedTime())")
        
        audioPlayer.pauseAudio()
        nowPlayingTimer?.invalidate()
        
        archiveData()
        
        updateUIInfo()
        
        self.audioPlayer = nil
    }
    
    func handleAudioPaused() {
        Logger.logDetails(msg: "Entered")
        
        nowPlayingTimer?.invalidate()
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        Logger.logDetails(msg:"calling archiveData() with songElapsedTime = \(audioPlayer.songElapsedTime())")
        
        archiveData()
        
        updateUIInfo()
        
        self.audioPlayer = nil
    }
    
    func playOrPauseAudio() {
        Logger.logDetails(msg: "Entered")
        
        if audioPlayer == nil {
            createAudioPlayer()
            audioPlayer?.updateSongTime(archivedElapsedTime)
        }
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        let audioWasPlaying = audioPlayer.isAudioPlaying()
        
        audioPlayer.playOrPauseAudio()
        
        audioWasPlaying ? nowPlayingTimer?.invalidate() : createNowPlayingTimer()
        
        archiveData()
        
        updateUIInfo()
        
        if audioWasPlaying {
            self.audioPlayer = nil
        }
    }
    
    func createAudioPlayer() {
        Logger.logDetails(msg: "Entered")
        
        guard let song = song else {
            Logger.logDetails(msg:"song is nil")
            return
        }
        
        guard let songURL = NSKeyedUnarchiver.unarchiveObject(with: song.assetURL as Data) as? URL else {
            Logger.logDetails(msg:"songURL is nil")
            return
        }
        
        audioPlayer = AudioPlayer(url: songURL)
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg:"Audio player creation failed")
            return
        }
        
        Logger.logDetails(msg:"created audioPlayer for \(song) with url \(songURL)")
        
        audioPlayer.delegate = self
        Logger.logDetails(msg:"Audio player delegate assigned to \(type(of: self)) for \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
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
        
        guard audioPlayer != nil else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        playOrPauseAudio()
        updateUIInfo()
    }

    func loadNextSong() {
        let shuffleFlag = UserPreferences().shuffleFlagValue()
        
        Logger.logDetails(msg:"Called with UserPreferences().shuffleFlagValue() = \(shuffleFlag)")
        
        if shuffleFlag {
            loadNextShuffleSong()
        } else {
            if !currentSongIsLastSong() {
                if let songIndex = returnSongListIndexForSong(song) {
                    let nextSongPersistentKey = songList[songIndex + 1].persistentKey
                    let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
                    song = SongFetcher.fetchSongBySongPersistentKey(nextSongPersistentKey, databaseInterface: databaseInterface)
                }
            }
        }
        
        createAudioPlayer()
        updateUIInfo()
    }

    func goBack() {
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        let elapsedTime = audioPlayer.songElapsedTime()
        Logger.logDetails(msg:"Called with elapsedTime = \(elapsedTime)")
        
        if elapsedTime > 1.0 {
            Logger.writeToLogFile("Calling audioPlayer.updateSongTime(0.0)")
            
            updateSongTime(0.0)
        } else {
            let audioPlaying = audioPlayer.isAudioPlaying()
            Logger.writeToLogFile("audioPlaying = \(audioPlaying)")
            audioPlaying ? playPreviousSong() : loadPreviousSong()
        }
    }
    
    func loadPreviousSong() {
        Logger.logDetails(msg: "Entered")
        
        guard let last = previousSongs.last else {
            Logger.logDetails(msg: "last is nil")
            return
        }
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        song = SongFetcher.fetchSongBySongPersistentKey(last.int64Value, databaseInterface: databaseInterface)

        guard let song = song else {
            Logger.logDetails(msg: "song is nil")
            return
        }
        
        audioPlayer?.endSong()
        
        previousSongs.removeLast()
        
        archiveData()
        
        Logger.logDetails(msg:"set song to \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
        
        createAudioPlayer()
        updateUIInfo()
    }
    
    func playPreviousSong() {
        Logger.logDetails(msg: "Entered")
        
        loadPreviousSong()
        playSong(false)
        updateUIInfo()
    }
    
    func playNextSong() {
        Logger.logDetails(msg: "Entered")

        loadNextSong()
        
        guard song != nil else {
            Logger.logDetails(msg: "song is nil")
            return
        }
        
        playSong(false)
    }

    func currentSongIsLastSong() -> Bool {
        Logger.logDetails(msg: "Entered")
        
        return song?.summary.persistentKey == songList[songList.count - 1].persistentKey
    }
    
    func songElapsedTime() -> TimeInterval {
        //Logger.logDetails(msg: "Entered")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return 0
        }
        
        return audioPlayer.songElapsedTime()
    }
    
    func isAudioPlaying() -> Bool {
        Logger.logDetails(msg: "Entered")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return false
        }
        
        return audioPlayer.isAudioPlaying()
    }
    
    func updateSongTime(_ songTime: TimeInterval) {
        Logger.logDetails(msg: "Entered")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
 
        Logger.writeToLogFile("Calling audioPlayer.updateSongTime(\(songTime))")
        
        audioPlayer.updateSongTime(songTime)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.songTimeUpdated"), object:self)
    }

    func adjustVolume(_ volume: Float) {
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
            return
        }
        
        audioPlayer.adjustVolume(volume)
    }
    
    func returnSongListIndexForSong(_ song: Song?) -> Int? {
        Logger.logDetails(msg: "Entered")
        
        guard song != nil else {
            Logger.logDetails(msg:"song is nil")
            return nil
        }
        
        //Logger.logDetails(msg:"songList.count = \(songList.count)")
        
        let returnValue = songList.index(where: { $0.persistentKey == song!.summary.persistentKey })

        //Logger.logDetails(msg:"returning \(returnValue)")

        return returnValue
    }
    
    func returnTrackOfTracksForSong(_ song: Song) -> (trackNumber: Int, totalTracks: Int) {
        Logger.logDetails(msg: "Entered")
        
        guard let songIndex = returnSongListIndexForSong(song) else {
            Logger.logDetails(msg: "songIndex is nil")
            return (-1, songList.count)
        }
        
        return (songIndex + 1, songList.count)
    }
    
    // Contents of albumTracks: array of NSOrderedSets
    // What songList needs: SongPlayRecords
    
    func fillSongListFromAlbumTracks(_ albumTracks:Array<NSOrderedSet>, containsMultipleAlbums: Bool) {
        Logger.logDetails(msg: "Entered")
        
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
        Logger.logDetails(msg: "Entered")
        
        previousSongs = []
        songList = SongFetcher.fetchPlaylistSongListPersistentKeysAndLastPlayedTimes(playlistPersistentID)
        songListType = "Playlist Songs List"
        
        createSongShuffler()
    }
    
    func fillSongListWithAllSongs() {
        Logger.logDetails(msg: "Entered")
        
        previousSongs = []
        songList = SongFetcher.fetchSongListPersistentKeysAndLastPlayedTimes(nil)
        songListType = "All Songs List"
        
        createSongShuffler()
    }

    func skipToNextSong() {
        Logger.logDetails(msg: "Entered")
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg: "audioPlayer is nil")
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
        Logger.logDetails(msg: "Entered")
        
        if UserPreferences().shuffleFlagValue() {
            songShuffler = SongShuffler(songList: songList)
        }
    }
    
    func loadNextShuffleSong() {
        Logger.logDetails(msg: "Entered")
        
        if songShuffler == nil {
            Logger.logDetails(msg:"Called with nil songShuffler")
        }
        
        song = songShuffler?.fetchShuffleSong()
        
        Logger.logDetails(msg:"returning \(song)")
    }
    
    func shuffleAll() {
        Logger.logDetails(msg: "Entered")
        
        previousSongs = []
        
        createSongShuffler()
        
        loadNextShuffleSong()
    }
    
    func updateNowPlayingInfoCenter() {
        //Logger.logDetails(msg: "Entered")
        
        guard let song = self.song else {
            Logger.logDetails(msg: "song is nil")
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
        
        guard let audioPlayer = audioPlayer else {
            Logger.logDetails(msg:"audioPlayer is nil")
            return
        }
        
        nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer.songElapsedTime() as Double)
        //Logger.logDetails(msg:"elapsed time = \(nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime])")

        if let songArtwork = song.albumArtwork() {
            nowPlayingDict[MPMediaItemPropertyArtwork] = songArtwork
        } else {
            Logger.logDetails(msg:"songArtwork is nil")
        }
        
        //Logger.logDetails(msg:"nowPlayingDict = \(nowPlayingDict)")
        
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
            Logger.logDetails(msg: "Entered")
            
            self.nowPlayingTimer?.invalidate()
            
            guard let song = self.song else {
                Logger.logDetails(msg:"song is nil")
                return
            }

            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            song.updateLastPlayedTime(DateTimeUtilities.returnNowTimeInterval(), databaseInterface: databaseInterface)
                
            self.previousSongs.append(NSNumber(value: song.summary.persistentKey as Int64))
            
            if let songShuffler = self.songShuffler {
                songShuffler.moveOldSongToPlayedSongsList(song)
            } else {
                Logger.logDetails(msg:"songShuffler is nil")
            }
            
            Logger.logDetails(msg:"found a non-nil song")

            self.archiveData()
            
            if let delegate = self.delegate {
                delegate.audioPlayerDidFinishPlaying?(player, successfully: flag)
            } else {
                Logger.logDetails(msg:"delegate is nil")
            }
            
            self.playNextSong()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Logger.logDetails(msg: "Entered")
        
        delegate?.audioPlayerDecodeErrorDidOccur?(player, error: error)
    }
}
