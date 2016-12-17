//
//  ArtistsViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class ArtistsViewController: MediaListViewController, MediaListVCDelegate {

    var genreFilter:String?
    
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
        if let artistSummary = summaryItem as? ArtistSummary {
            cell.titleLabel.text = artistSummary.name
            cell.subtitleLabel.text = "\(artistSummary.forArtist.albums.count) albums"
            cell.persistentID = artistSummary.persistentID
        }
    }
    
    func returnMediaItemType() -> String {
        return "ArtistSummary"
    }
    
    func returnSegueIdentifier() -> String {
        return "artistSelectionSegue"
    }
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?) {
        sortKey = "indexCharacter"
        secondarySortKey = "strippedName"
        sectionNameKeyPath = "indexCharacter"
        
        if genreFilter != nil {
            predicate = NSPredicate(format:"ANY forArtist.genres.summary.name == %@", genreFilter!)
        }
    }

    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        // This calll takes the cell's persistentID and returns a corresponding Core Data object
        return ArtistFetcher.fetchArtistSummaryWithPersistentID(cell.persistentID, databaseInterface: DatabaseInterface(concurrencyType: .mainQueueConcurrencyType))
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "artistSelectionSegue" {
            if let selectedObject:AnyObject = returnSelectedObject() {
                if let artistSummary:ArtistSummary = selectedObject as? ArtistSummary {
                    if let albumDetailViewController:AlbumDetailViewController = segue.destination as? AlbumDetailViewController {
                        albumDetailViewController.artistSummary = artistSummary
                    }
                }
            }
        }
    }

}
