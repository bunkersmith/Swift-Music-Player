//
//  MediaListVC+SearchFunctions.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension MediaListViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    func createSearchController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        resultTableViewController = storyboard.instantiateViewController(withIdentifier: "ResultsTableViewController") as! UITableViewController
        resultTableViewController.tableView.delegate = self
        resultTableViewController.tableView.dataSource = self
        
        resultSearchController = UISearchController(searchResultsController: resultTableViewController)
        resultSearchController.delegate = self
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.barStyle = .black
        resultSearchController.searchBar.showsCancelButton = true
        resultSearchController.searchBar.tintColor = UIColor.white
        resultSearchController.searchBar.delegate = self
        
        if let localSearchTextField = resultSearchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField = localSearchTextField
            searchTextField!.textColor = UIColor.white
        }
        
        self.tableView.tableHeaderView = resultSearchController.searchBar
        hideSearchBar()
    }
    
    func showSearchBar() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.tableView.contentOffset = CGPoint.zero
            if self.searchTextField != nil {
                self.searchTextField!.becomeFirstResponder()
            }
        })
    }
    
    func hideSearchBar() {
        if self.tableView.contentOffset == CGPoint.zero {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.tableView.contentOffset = CGPoint(x: 0.0, y: self.tableView.tableHeaderView!.frame.size.height)
            })
        }
    }
    
    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    // MARK: - Search Results Updater
    func updateSearchResults(for searchController: UISearchController)
    {
        var searchPredicate:NSPredicate?
        
        if searchController.searchBar.text == "" {
            searchPredicate = nil
        }
        else {
            searchPredicate = NSPredicate(format: "searchKey CONTAINS[c] %@", searchController.searchBar.text!)
        }
        createFetchedResultsController(searchPredicate)
        
        resultTableViewController.tableView.reloadData()
    }
}
