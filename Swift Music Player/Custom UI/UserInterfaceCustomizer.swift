//
//  UserInterfaceCustomizer.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class UserInterfaceCustomizer: NSObject {

    class func createCustomGUI()
    {
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.white ]
        
        UITabBar.appearance().backgroundImage = UIImage(named: "tab-bar.png")
        UITabBar.appearance().selectionIndicatorImage = UIImage(named: "tab-bar-item-selected.png")
        UITabBar.appearance().tintColor = UIColor.black
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), NSShadowAttributeName: shadow]
        UITabBarItem.appearance().setTitleTextAttributes(titleTextAttributes, for:UIControlState())
    }
}
