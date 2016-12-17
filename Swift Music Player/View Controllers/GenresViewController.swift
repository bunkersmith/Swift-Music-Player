//
//  GenresViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/16/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import CoreData
import UIKit

class GenresViewController: MediaListViewController, MediaListVCDelegate {

    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        useFetchedResultsController = true
        mlvcDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
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
        if let genreSummary = summaryItem as? GenreSummary {
            cell.titleLabel.text = genreSummary.name
            cell.subtitleLabel.text = "\(genreSummary.forGenre.artists.count) artists"
            cell.persistentID = genreSummary.persistentID
        }
    }
    
    func returnMediaItemType() -> String {
        return "GenreSummary"
    }

    func returnSegueIdentifier() -> String {
        return "genreSelectionSegue"
    }
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?) {
        sortKey = "indexCharacter"
        secondarySortKey = nil
        sectionNameKeyPath = "indexCharacter"
    }

    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject? {
        // This calll takes the cell's persistentID and returns a corresponding Core Data object
        return GenreFetcher.fetchGenreSummaryWithPersistentID(cell.persistentID, databaseInterface: databaseInterface)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "genreSelectionSegue" {
            if let artistsViewController = segue.destination as? ArtistsViewController {
                if let selectedObject:AnyObject = returnSelectedObject() {
                    if let genreSummary:GenreSummary = selectedObject as? GenreSummary {
                        artistsViewController.genreFilter = genreSummary.name
                    }
                }
            }
        }
    }
}
