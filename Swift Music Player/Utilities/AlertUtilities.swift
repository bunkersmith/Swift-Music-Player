//
//  AlertUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation

class AlertUtilities {
    
    class func showNoButtonAlert(_ viewController:UIViewController, title: String, message:String) -> UIAlertController {
        
        let noButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        viewController.present(noButtonAlert, animated:true, completion: nil)
        
        return noButtonAlert
    }
    
    class func showOkButtonAlert(_ viewController:UIViewController, title: String, message:String, buttonHandler:((UIAlertAction) -> Void)?) {
        let okButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        okButtonAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: buttonHandler))
        viewController.present(okButtonAlert, animated:true, completion: nil)
        //return okButtonAlert
    }
    
}
