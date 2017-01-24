//
//  TabBarViewController.swift
//  Swift 3 Music Player
//
//  Created by CarlSmith on 12/17/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.logDetails(msg: "Entered")
        
        delegate = self
        
        if SongsInterface.totalSongCount() == 0 {
            selectItem(title: "More")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectItem(title: String) {
        guard let tabBarItems = tabBar.items else {
            return
        }
        
        let tabBarItemIndex = tabBarItems.index { (tabBarItem) -> Bool in
            return tabBarItem.title == title
        }
        
        guard let tbItemIndex = tabBarItemIndex else {
            return
        }

        selectedIndex = tbItemIndex
    }
    
    // MARK: TabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        Logger.logDetails(msg: "Entered")
        
        return !DatabaseManager.instance.databaseBuildInProgress
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Logger.logDetails(msg: "Entered")
        
        /*
         if ([viewController class] == [UINavigationController class])
         {
         UINavigationController *navigationController = (UINavigationController *)viewController;
         [navigationController popToRootViewControllerAnimated:NO];
         }
         */
    }
}
