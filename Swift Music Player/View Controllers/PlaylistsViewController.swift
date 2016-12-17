//
//  PlaylistsViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class PlaylistsViewController: MediaListViewController, MediaListVCDelegate {
    var ultimatePlaylistSummary: PlaylistSummary?
    
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mlvcDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ultimatePlaylistSummary = nil
        
        if SongManager.instance.song != nil {
            nowPlayingButton.show()
        }
        else {
            nowPlayingButton.hide()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shouldUseFetchResultsController() -> Bool {
        return true
    }
    
    func configureSummaryCell(_ cell: MediaListTableViewCell, summaryItem: AnyObject) {
        if let playlistSummary = summaryItem as? PlaylistSummary {
            cell.titleLabel.text = playlistSummary.title
            cell.subtitleLabel.text = "\(playlistSummary.forPlaylist.songSummaries.count) songs"
            cell.persistentID = playlistSummary.persistentID
        }
    }
    
    func returnMediaItemType() -> String {
        return "PlaylistSummary"
    }
    
    func returnSegueIdentifier() -> String {
        return "playlistSelectionSegue"
    }
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?) {
        sortKey = "title"
        secondarySortKey = nil
        sectionNameKeyPath = nil
    }
    
    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        // This calll takes the cell's persistentID and returns a corresponding Core Data object
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        return PlaylistFetcher.fetchPlaylistSummaryWithPersistentID(cell.persistentID, databaseInterface: databaseInterface)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playlistSongsViewController:PlaylistSongsViewController = segue.destination as? PlaylistSongsViewController {
            if segue.identifier == "playlistSelectionSegue" {
                if let selectedObject:AnyObject = returnSelectedObject() {
                    if let playlistSummary:PlaylistSummary = selectedObject as? PlaylistSummary {
                        playlistSongsViewController.playlistTitle = playlistSummary.title
                        playlistSongsViewController.playlistPersistentID = playlistSummary.persistentID
                    }
                }
                return
            }
        }
    }
}
