//
//  EmailPlayedSongsViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 10/11/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailPlayedSongsViewController: EmailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestMailComposeViewController() {
        composeMailViewControllerRequested = true
    }
    
    override func configureMailComposeViewController() -> MFMailComposeViewController?
    {
        let returnValue = MFMailComposeViewController()
        returnValue.mailComposeDelegate = self
        returnValue.setSubject("Swift Music Player Played Songs File")
        returnValue.setToRecipients(["carl@afterburnerimages.com"])
        Logger.writeLogFileToDisk()
        // Attach the played songs file to the email
        if let playedSongsFileData = FileUtilities.returnPlayedSongsFileAsNSData() {
            returnValue.addAttachmentData(playedSongsFileData as Data, mimeType: "text", fileName: "Swift-Music-Player-PlayedSongs.txt")
            let currentTimeString:String = DateTimeUtilities.returnStringFromNSDate(Date())
            
            // Fill out the email body text
            let emailBody = "Swift Music Player Played Songs File sent at " + currentTimeString
            returnValue.setMessageBody(emailBody, isHTML: false)
            return returnValue
        }
        else {
            Logger.writeToLogFile("displayMailComposerSheet could not convert log file to NSData")
            return nil
        }
    }
}
