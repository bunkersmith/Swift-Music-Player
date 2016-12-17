//
//  AlbumsViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class AlbumsViewController: MediaListViewController, MediaListVCDelegate {

    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shouldUseFetchResultsController() -> Bool {
        return true
    }
    
    func configureSummaryCell(_ cell: MediaListTableViewCell, summaryItem: AnyObject) {
        if let albumSummary = summaryItem as? AlbumSummary {
            cell.titleLabel.text = albumSummary.title
            cell.subtitleLabel.text = albumSummary.artistName
            cell.persistentID = albumSummary.persistentID
        }
    }
    
    func returnMediaItemType() -> String {
        return "AlbumSummary"
    }
    
    func returnSegueIdentifier() -> String {
        return "albumSelectionSegue"
    }
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?) {
        sortKey = "indexCharacter"
        secondarySortKey = "strippedTitle"
        sectionNameKeyPath = "indexCharacter"
    }
    
    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        // This calll takes the cell's persistentID and returns a corresponding Core Data object
        return AlbumFetcher.fetchAlbumSummaryWithPersistentID(cell.persistentID)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumSelectionSegue" {
            if let selectedObject:AnyObject = returnSelectedObject() {
                if let albumSummary:AlbumSummary = selectedObject as? AlbumSummary {
                    if let albumDetailViewController:AlbumDetailViewController = segue.destination as? AlbumDetailViewController {
                        let album:Album = albumSummary.forAlbum
                        albumDetailViewController.artistSingleAlbum = album
                        albumDetailViewController.artistSummary = album.artist!.summary
                    }
                }
            }
        }
    }

}
