//
//  SliderExtensions.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

extension UISlider {
    
    func configureSlider(_ minTrackImageName: String, maxTrackImageName: String, thumbImageName: String) {
        let minTrackImage = UIImage(named: minTrackImageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0))
        let maxTrackImage = UIImage(named: maxTrackImageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0))
        let thumbImage = UIImage(named: thumbImageName)
        setMinimumTrackImage(minTrackImage, for: UIControlState())
        setMinimumTrackImage(minTrackImage, for: .selected)
        setMaximumTrackImage(maxTrackImage, for: UIControlState())
        setMaximumTrackImage(maxTrackImage, for: .selected)
        setThumbImage(thumbImage, for: UIControlState())
        setThumbImage(thumbImage, for: .selected)
    }

}
