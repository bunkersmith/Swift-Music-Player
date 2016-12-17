//
//  TabBarControllerDelegate.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/30/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class TabBarControllerDelegate: NSObject, UITabBarControllerDelegate {

    // MARK: TabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !DatabaseManager.instance.databaseBuildInProgress
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        /*
         if ([viewController class] == [UINavigationController class])
         {
         UINavigationController *navigationController = (UINavigationController *)viewController;
         [navigationController popToRootViewControllerAnimated:NO];
         }
         */
    }
    
}
