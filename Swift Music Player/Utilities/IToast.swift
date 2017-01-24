//
//  IToast.swift
//  Swift Music Player
//
//  Created by CarlSmith on 7/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class IToast: NSObject {
    var completionHandler:((Void) -> ())?
    
    func showToast(_ viewController: UIViewController, alertTitle: String, alertMessage: String, duration: Int64, callersCompletionHandler: (() -> ())?) {
        completionHandler = callersCompletionHandler
        let toastAlert:UIAlertController = AlertUtilities.showNoButtonAlert(viewController, title: alertTitle, message: alertMessage)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(duration * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            toastAlert.dismiss(animated: true, completion: nil)
            if self.completionHandler != nil {
                self.completionHandler!()
            }
        })
    }
}
