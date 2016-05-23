//
//  SliderExtensions.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

extension UISlider {
    
    func configureSlider(minTrackImageName: String, maxTrackImageName: String, thumbImageName: String) {
        let minTrackImage = UIImage(named: minTrackImageName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0))
        let maxTrackImage = UIImage(named: maxTrackImageName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0))
        let thumbImage = UIImage(named: thumbImageName)
        setMinimumTrackImage(minTrackImage, forState: .Normal)
        setMinimumTrackImage(minTrackImage, forState: .Selected)
        setMaximumTrackImage(maxTrackImage, forState: .Normal)
        setMaximumTrackImage(maxTrackImage, forState: .Selected)
        setThumbImage(thumbImage, forState: .Normal)
        setThumbImage(thumbImage, forState: .Selected)
    }

}