//
//  IToast.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class IToast: NSObject {
    var completionHandler:((Void) -> ())?
    
    func showToast(viewController: UIViewController, alertTitle: String, alertMessage: String, duration: Int64, callersCompletionHandler: (() -> ())?) {
        completionHandler = callersCompletionHandler
        let toastAlert:UIAlertController = Utilities.showNoButtonAlert(viewController, title: alertTitle, message: alertMessage)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            toastAlert.dismissViewControllerAnimated(true, completion: nil)
            if self.completionHandler != nil {
                self.completionHandler!()
            }
        })
    }
}
