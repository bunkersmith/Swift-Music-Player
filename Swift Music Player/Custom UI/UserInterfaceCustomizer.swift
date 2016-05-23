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
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor() ]
        
        UITabBar.appearance().backgroundImage = UIImage(named: "tab-bar.png")
        UITabBar.appearance().selectionIndicatorImage = UIImage(named: "tab-bar-item-selected.png")
        UITabBar.appearance().tintColor = UIColor.blackColor()
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.blackColor()
        shadow.shadowOffset = CGSizeMake(1.0, 1.0)
        
        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), NSShadowAttributeName: shadow]
        UITabBarItem.appearance().setTitleTextAttributes(titleTextAttributes, forState:UIControlState.Normal)
    }
}
