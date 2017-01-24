//
//  MediaListVC+FetchedResultsControllerDelegate.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

extension MediaListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        /*
         Logger.logDetails(msg: "Entered")
         Logger.writeToLogFile("anObject = \(anObject)")
         if indexPath != nil {
         Logger.writeToLogFile("indexPath = \(indexPath)")
         }
         else {
         Logger.writeToLogFile("indexPath == nil")
         }
         if newIndexPath != nil {
         Logger.writeToLogFile("newIndexPath = \(newIndexPath)")
         }
         else {
         Logger.writeToLogFile("newIndexPath == nil")
         }
         Logger.writeToLogFile("fetchedResultsChangeType = \(Utilities.fetchedResultsChangeTypeToString(type))")
         */
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                self.configureCell(cell, atIndexPath: indexPath!)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
