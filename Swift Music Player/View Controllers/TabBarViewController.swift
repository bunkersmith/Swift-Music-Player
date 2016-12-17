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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
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
