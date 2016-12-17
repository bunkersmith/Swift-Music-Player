//
//  MediaListVC+TableViewDataSource.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension MediaListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.fetchedResultsController != nil {
            if let sections = self.fetchedResultsController.sections {
                return sections.count + 1
            }
        }
        return 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if useFetchedResultsController {
            return sectionIndexTitles
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if useFetchedResultsController && index == 0 {
            showSearchBar()
        }
        return index
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if useFetchedResultsController && section < sectionTitles.count {
            return sectionTitles[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if useFetchedResultsController {
            if section > 0 {
                let sectionInfo = self.fetchedResultsController.sections![section - 1]
                return sectionInfo.numberOfObjects
            }
            return 0
        }
        return songCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaListTableViewCell", for: indexPath) as! MediaListTableViewCell
        //Logger.writeToLogFile("Before self.configureCell call with indexPath \(indexPath.section), \(indexPath.row)")
        self.configureCell(cell, atIndexPath: indexPath)
        //Logger.writeToLogFile("After self.configureCell, cell at indexPath \(indexPath.section), \(indexPath.row) = \(cell.titleLabel.text), \(cell.subtitleLabel.text)")
        return cell
    }

}
