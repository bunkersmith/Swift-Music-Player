//
//  Utilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

class Utilities {
    
    class func convertSectionIndexTitles(_ fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) -> [String]
    {
        var returnValue:[String] = [UITableViewIndexSearch]
        
        for sectionIndexTitle:String in fetchedResultsController.sectionIndexTitles {
            if sectionIndexTitle == "_" {
                returnValue.append("#")
            }
            else {
                returnValue.append(sectionIndexTitle)
            }
        }
        
        return returnValue
    }
    
    class func convertSectionTitles(_ fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) -> [String]
    {
        var returnValue:[String] = [" "]
        
        if fetchedResultsController.sections != nil {
            if let fetchedResultsControllerSections = fetchedResultsController.sections {
                for sectionInfo:NSFetchedResultsSectionInfo in fetchedResultsControllerSections {
                    if sectionInfo.name == "_" {
                        returnValue.append("123")
                    }
                    else {
                        returnValue.append(sectionInfo.name)
                    }
                }
            }
        }
        
        return returnValue
    }
    
    class func indexOfTabBarItemNamed( _ tabBarController: UITabBarController?, itemName: String ) -> Int {
        var itemTabIndex = NSNotFound
        if tabBarController != nil {
            if tabBarController!.tabBar.items != nil {
                if let tabBarItems:[UITabBarItem] = tabBarController!.tabBar.items {
                    let itemTabIndexes = (tabBarItems as NSArray).indexesOfObjects(options: .concurrent, passingTest: { (tabBarAny, index, stop:UnsafeMutablePointer<ObjCBool>) -> Bool in
                        guard let tabBarItem = tabBarAny as? UITabBarItem else {
                            return false
                        }
                        return tabBarItem.title == itemName
                    })
                    if itemTabIndexes.count == 1 {
                        if itemTabIndexes.first != nil {
                            itemTabIndex = itemTabIndexes.first!
                        }
                    }
                }
            }
        }
        return itemTabIndex
    }
    
}
