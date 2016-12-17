//
//  SongManager.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/25/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation

class SongManager: NSObject, AVAudioPlayerDelegate {

    var song:Song?
    private var songListType = ""
    weak var delegate: AVAudioPlayerDelegate?
    
    private var audioPlayer: AudioPlayer?
    private var songList:[SongPlayRecord]!
    private var songShuffler:SongShuffler?

    // This class method initializes the static singleton pointer
    // if necessary, and returns the singleton pointer to the caller
    class var instance: SongManager {
        struct Singleton {
            static var instance:SongManager? = nil
            static var songManagerToken: dispatch_once_t = 0
        }
        dispatch_once(&Singleton.songManagerToken) {
            Singleton.instance = self.loadInstance()
        }
        return Singleton.instance!
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        //self.logMessages = aDecoder.decodeObjectForKey("logMessages") as! [String]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(self.logMessages, forKey:"logMessages")
    }
    
    func archiveData() {
        NSKeyedArchiver.archiveRootObject(self, toFile:FileUtilities.songManagerArchiveFilePath())
    }
    
    class func loadInstance() -> SongManager
    {
        if let songManagerData:SongManager = NSKeyedUnarchiver.unarchiveObjectWithFile(FileUtilities.songManagerArchiveFilePath()) as? SongManager {
            return songManagerData
        }
        return SongManager()
    }

    func playOrPauseAudio() {
        guard audioPlayer != nil else {
            return
        }
        
        audioPlayer!.playOrPauseAudio()
    }
    
    func playSong() {
        guard let songURL = NSKeyedUnarchiver.unarchiveObjectWithData(song!.assetURL) as? NSURL else {
            NSLog("songURL is nil in \(#function)")
            return
        }
        
        audioPlayer = AudioPlayer(url: songURL)
        
        guard audioPlayer != nil else {
            Logger.writeToLogFile("Audio player creation failed in \(#function)")
            return
        }
        
        audioPlayer!.delegate = self
        playOrPauseAudio()
    }

    func songElapsedTime() -> NSTimeInterval {
        guard audioPlayer != nil else {
            return 0
        }
        
        return audioPlayer!.songElapsedTime()
    }
    
    func isAudioPlaying() -> Bool {
        guard audioPlayer != nil else {
            return false
        }
        
        return audioPlayer!.isAudioPlaying()
    }
    
    func updateSongTime(songTime: NSTimeInterval) {
        guard audioPlayer != nil else {
            return
        }
        
        audioPlayer!.updateSongTime(songTime)
    }

    func adjustVolume(volume: Float) {
        guard audioPlayer != nil else {
            return
        }
        
        audioPlayer!.adjustVolume(volume)
    }
    
    func returnTrackOfTracksForSong(song: Song) -> (trackNumber: Int, totalTracks: Int) {
        guard let songIndex = songList.indexOf({ $0.persistentKey == song.summary.persistentKey }) else {
            return (-1, songList.count)
        }
        return (songIndex + 1, songList.count)
    }
    
    // Contents of albumTracks: array of NSOrderedSets
    // What songList needs: SongPlayRecords
    
    func fillSongListFromAlbumTracks(albumTracks:Array<NSOrderedSet>, containsMultipleAlbums: Bool) {
        songList = []
         
        for albumOrderedSet:NSOrderedSet in albumTracks {
            for (_, object) in albumOrderedSet.enumerate() {
                let song = object as! Song
                songList.append(SongPlayRecord(persistentKey: song.summary.persistentKey, lastPlayedTime: song.summary.lastPlayedTime, title: song.summary.title))
            }
        }
        
        if containsMultipleAlbums {
            songListType = "Multi-Album Song List"
        }
        else {
            songListType = "Album Songs List"
        }
     }
    
    func fillSongListFromPlaylistSongs(playlistPersistentID:UInt64) {
        let playListPredicate = NSPredicate(format:"ANY inPlaylists.summary.persistentID == %llu", playlistPersistentID)
        songList = SongFetcher.fetchSongPersistentKeysAndLastPlayedTimes(playListPredicate)
        songListType = "Playlist Songs List"
    }
    
    func fillSongListWithAllSongs() {
        songList = SongFetcher.fetchSongPersistentKeysAndLastPlayedTimes(nil)
        songListType = "All Songs List"
    }
    
    // MARK: Audio Player Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        NSLog("\(#function) called")
        
        delegate?.audioPlayerDidFinishPlaying?(player, successfully: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        NSLog("\(#function) called")
        
        delegate?.audioPlayerDecodeErrorDidOccur?(player, error: error)
    }

    func createSongShuffler() {
        songShuffler = SongShuffler(songList: songList)
    }
    
    func loadNextShuffleSong() {
        song = songShuffler?.fetchShuffleSong()
    }
    
    func shuffleAll() {
        createSongShuffler()
        loadNextShuffleSong()
    }
}
