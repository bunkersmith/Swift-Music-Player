//
//  MarqueeLabelExtensions.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

extension MarqueeLabel {
    func configureMarqueeLabel(text: String) {
        textAlignment = .Center
        self.text = text
        marqueeType = .MLContinuous
        rate = 30.0
        trailingBuffer = 20
    }
    
}