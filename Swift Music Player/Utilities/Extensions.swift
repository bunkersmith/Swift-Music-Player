//
//  Extensions.swift
//  Macro Minder
//
//  Created by CarlSmith on 5/18/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension Float {
    func string(minFractionDigits:Int, maxFractionDigits:Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.stringFromNumber(self) ?? "\(self)"
    }
}

