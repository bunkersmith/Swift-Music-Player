//
//  SongsViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class SongsViewController: MediaListViewController, MediaListVCDelegate {

    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mlvcDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let songCount = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).countOfEntitiesOfType("SongSummary", predicate: nil)
        songCountLabel.text = "\(songCount) Songs"
        
        if SongManager.instance.song != nil {
            nowPlayingButton.show()
        }
        else {
            nowPlayingButton.hide()
        }
    }
    
    func shouldUseFetchResultsController() -> Bool {
        return true
    }
    
    func configureSummaryCell(_ cell: MediaListTableViewCell, summaryItem: AnyObject) {
        if let songSummary = summaryItem as? SongSummary {
            cell.titleLabel.text = songSummary.title
            cell.subtitleLabel.text = songSummary.artistName
            cell.persistentID = songSummary.persistentID
        }
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
    }

    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        // This calll takes the cell's persistentID and returns a corresponding Core Data object
        return SongFetcher.fetchSongSummaryWithPersistentID(cell.persistentID, databaseInterface: databaseInterface)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "nowPlayingSegue" {
            if let nowPlayingViewController:NowPlayingViewController = segue.destination as? NowPlayingViewController {
                nowPlayingViewController.songNeedsPlaying = true
                
                let songManager = SongManager.instance
                songManager.fillSongListWithAllSongs()

                if segue.identifier == "songSelectionSegue" {
                    if let selectedObject:AnyObject = returnSelectedObject() {
                        if let songSummary:SongSummary = selectedObject as? SongSummary {
                            songManager.song = songSummary.forSong
                        }
                        return
                    }
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
