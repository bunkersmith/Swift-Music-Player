//
//  MediaListViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

protocol MediaListVCDelegate: class {
    func shouldUseFetchResultsController() -> Bool;
    
    func configureSummaryCell(_ cell: MediaListTableViewCell, summaryItem: AnyObject);
    
    func returnMediaItemType() -> String;
    
    func returnSegueIdentifier() -> String;
    
    func configureFetchedResultsController(_ sortKey: inout String!, secondarySortKey: inout String?, sectionNameKeyPath: inout String?, predicate:inout NSPredicate?);
    
    func returnObjectFromCell(_ cell: MediaListTableViewCell, databaseInterface:DatabaseInterface) -> AnyObject?;
}

class MediaListViewController: PortraitViewController {

    weak var mlvcDelegate: MediaListVCDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    var resultSearchController: UISearchController!
    var resultTableViewController: UITableViewController!
    var searchString: String!

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var sectionTitles:[String]!
    var sectionIndexTitles:[String]!
    
    var mediaItemType: String!
    var segueIdentifier:String!
    var sortKey: String!
    var secondarySortKey, sectionNameKeyPath: String?
    var predicate:NSPredicate?
    var searchTextField:UITextField?
    
    var useFetchedResultsController:Bool = false
    var songCount:Int = 0
    var playlistSongSummaries:NSOrderedSet!
    
    lazy fileprivate var databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Logger.logDetails(msg:"Entered")
        
        addScrollAreaView()
        
        mediaItemType = mlvcDelegate?.returnMediaItemType()
        segueIdentifier = mlvcDelegate?.returnSegueIdentifier()
        sortKey = ""
        
        useFetchedResultsController = (mlvcDelegate?.shouldUseFetchResultsController())!
        
        if useFetchedResultsController {
            createFetchedResultsController(nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
        
        super.viewDidDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addScrollAreaView() {
        var frame = tableView.bounds
        frame.origin.y = -frame.size.height;
        let blackView = UIView(frame: frame)
        blackView.backgroundColor = UIColor.black
        tableView.addSubview(blackView)
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        var summaryItem: AnyObject? = nil
        if useFetchedResultsController {
            let trueIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section - 1)
            if fetchedResultsController != nil {
                summaryItem = fetchedResultsController.object(at: trueIndexPath)
            }
        }
        else {
            summaryItem = playlistSongSummaries.object(at: (indexPath as NSIndexPath).row) as AnyObject?
        }
        if summaryItem != nil {
            //Logger.writeToLogFile("summaryItem at indexPath \(indexPath.section), \(indexPath.row) = \(summaryItem)")
            mlvcDelegate?.configureSummaryCell(cell as! MediaListTableViewCell, summaryItem: summaryItem!)
        }
    }
    
    func createFetchedResultsController(_ searchPredicate:NSPredicate?) {
        mlvcDelegate?.configureFetchedResultsController(&sortKey, secondarySortKey: &secondarySortKey, sectionNameKeyPath: &sectionNameKeyPath, predicate:&predicate)
        
        var compoundPredicate:NSCompoundPredicate?
        if predicate != nil {
            if searchPredicate != nil {
                compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[predicate!, searchPredicate!])
            }
            else {
                compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[predicate!])
            }
        }
        else {
            if (searchPredicate != nil) {
                compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[searchPredicate!])
            }
        }
        
        fetchedResultsController = databaseInterface.createFetchedResultsController(mediaItemType, sortKey: sortKey, secondarySortKey: secondarySortKey, sectionNameKeyPath: sectionNameKeyPath, predicate: compoundPredicate)
        if fetchedResultsController != nil {
            fetchedResultsController.delegate = self
            sectionTitles = Utilities.convertSectionTitles(fetchedResultsController)
            sectionIndexTitles = Utilities.convertSectionIndexTitles(fetchedResultsController)
            tableView.reloadData()
        }
    }
    
    func returnSelectedObject() -> AnyObject? {
        var selectedObject:AnyObject? = nil
        var selectedIndexPath:IndexPath?
        
        if resultTableViewController != nil {
            selectedIndexPath = resultTableViewController.tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                if let cell = resultTableViewController.tableView.cellForRow(at: selectedIndexPath!) as? MediaListTableViewCell {
                    selectedObject = mlvcDelegate?.returnObjectFromCell(cell, databaseInterface: databaseInterface)
                }
                resultTableViewController.tableView.deselectRow(at: selectedIndexPath!, animated: true)
                resultSearchController.isActive = false
            }
        }
        if selectedIndexPath == nil {
            selectedIndexPath = tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                if useFetchedResultsController {
                    let trueSelectedIndexPath = IndexPath(row: (selectedIndexPath! as NSIndexPath).row, section: (selectedIndexPath! as NSIndexPath).section - 1)
                    selectedObject = fetchedResultsController.object(at: trueSelectedIndexPath)
                    tableView.deselectRow(at: trueSelectedIndexPath, animated: true)
                }
                else {
                    selectedObject = playlistSongSummaries.object(at: (selectedIndexPath! as NSIndexPath).row) as AnyObject?
                    tableView.deselectRow(at: selectedIndexPath!, animated: true)
                }
            }
        }
        
        //Logger.writeToLogFile("selectedObject at selectedIndexPath \(selectedIndexPath!.section), \(selectedIndexPath!.row) = \(selectedObject)")
        return selectedObject
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y <= 0 && searchTextField != nil {
            searchTextField!.becomeFirstResponder()
        }
    }
}
