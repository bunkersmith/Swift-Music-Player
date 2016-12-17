//
//  PortraitViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/10/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class PortraitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
        super.viewWillDisappear(animated)
    }

    func rotated()
    {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
        {
            CoverFlowViewController.segueToCoverFlow(self)
        }
    }
}
