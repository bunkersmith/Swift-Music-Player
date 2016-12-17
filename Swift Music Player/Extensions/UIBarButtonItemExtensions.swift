//
//  UIBarButtonItemExtensions.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/11/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    func hide() {
        isEnabled = false
        tintColor = UIColor.clear
    }
    
    func show() {
        isEnabled = true
        tintColor = nil
    }
    
}
