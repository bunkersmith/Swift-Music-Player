//
//  PlaylistSongsViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class PlaylistSongsViewController: MediaListViewController, MediaListVCDelegate {

    var playlistTitle:String!
    var playlistPersistentID:UInt64!
    
    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(NSNumber(value: playlistPersistentID as UInt64), forKey: "playlistPersistentID")
        coder.encode(playlistTitle, forKey: "playlistTitle")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        let playlistPersistentIDNumber:NSNumber = coder.decodeObject(forKey: "playlistPersistentID") as! NSNumber
        playlistPersistentID = playlistPersistentIDNumber.uint64Value
        playlistTitle = coder.decodeObject(forKey: "playlistTitle") as! String
        navigationItem.title = playlistTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mlvcDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SongManager.instance.song != nil {
            nowPlayingButton.show()
        }
        else {
            nowPlayingButton.hide()
        }
        
        navigationItem.title = playlistTitle

        songCountLabel.text = "\(songCount) Songs"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSummaryCell(_ cell: MediaListTableViewCell, summaryItem: AnyObject) {
        if let songSummary = summaryItem as? SongSummary {
            cell.titleLabel.text = songSummary.title
            cell.subtitleLabel.text = songSummary.artistName
            cell.persistentID = songSummary.persistentID
        }
    }
    
    func shouldUseFetchResultsController() -> Bool {
        if let playlistPID = playlistPersistentID {
            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
            let predicate = NSPredicate(format:"ANY inPlaylists.summary.persistentID == %llu", playlistPID)
            songCount = databaseInterface.countOfEntitiesOfType("SongSummary", predicate: predicate)
            
            if  songCount > 50 {
                return true
            } else {
                playlistSongSummaries = PlaylistFetcher.fetchPlaylistSongSummariesWithPersistentID(playlistPID, databaseInterface: databaseInterface)
            }
        }
        return false
    }
    
    func returnMediaItemType() -> String {
        return "SongSummary"
    }
    
    func returnSegueIdentifier() -> String {
        return "songSelectionSegue"
    }
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?) {
        sortKey = "indexCharacter"
        secondarySortKey = "strippedTitle"
        sectionNameKeyPath = "indexCharacter"
        
        guard let playlistPersistentID = self.playlistPersistentID else {
            Logger.writeToLogFile("\(type(of: self)).\(#function) detected a nil self.playlistPersistentID")
            return
        }
        predicate = NSPredicate(format:"ANY inPlaylists.summary.persistentID == %llu", playlistPersistentID)
    }
    
    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        return SongFetcher.fetchSongSummaryWithPersistentID(cell.persistentID, databaseInterface: databaseInterface)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "nowPlayingSegue" {
            if let nowPlayingViewController:NowPlayingViewController = segue.destination as? NowPlayingViewController {
                nowPlayingViewController.songNeedsPlaying = true
                
                let songManager = SongManager.instance
                songManager.fillSongListFromPlaylistSongs(playlistPersistentID)
                
                if segue.identifier == "songSelectionSegue" {
                    if let selectedObject:AnyObject = returnSelectedObject() {
                        if let songSummary:SongSummary = selectedObject as? SongSummary {
                            songManager.song = songSummary.forSong
                            nowPlayingViewController.songNeedsPlaying = true
                        }
                    }
                    return
                }
                
                if segue.identifier == "shuffleAllSegue" {
                    UserPreferences().changeShuffleFlagSetting(true)
                    songManager.shuffleAll()
                    return
                }
            }
        }
    }
}
