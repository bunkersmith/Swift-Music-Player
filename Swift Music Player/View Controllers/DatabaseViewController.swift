//
//  DatabaseViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class DatabaseViewController: UIViewController, DatabaseProgressDelegate, DeletionProgressDelegate {

    @IBOutlet weak var buildDatabaseButton: UIButton!
    @IBOutlet weak var buildingSongsListLabel: UILabel!
    @IBOutlet weak var buildingAlbumsListLabel: UILabel!
    @IBOutlet weak var buildingArtistsListLabel: UILabel!
    @IBOutlet weak var buildingPlaylistsListLabel: UILabel!
    @IBOutlet weak var buildingGenresListLabel: UILabel!
    @IBOutlet weak var operationProgressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    lazy private var databaseBuildQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Database Build Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var progressColor: UIColor = {
        return UIColor(red:0.0, green:0.75, blue:0.0, alpha:1.0)
    }()
    
    lazy var completionColor: UIColor = {
        return UIColor.greenColor()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func deletionProgressUpdate(progressLabelText: String, progressViewAlpha: CGFloat) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.operationProgressLabel.text = progressLabelText
            self.progressView.alpha = progressViewAlpha
        })
    }

    func progressUpdate(progressFraction:Float, operationType:DatabaseOperationType) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.progressView.alpha = 1.0
            self.operationProgressLabel.text = DatabaseProgress.databaseOperationTypeToString(operationType) + " Addition Progress"

            if progressFraction == 1.0 {
                self.progressView.progress = 0.0
                self.showBuildCompletionAlert(operationType)
                if operationType == .GenreOperation {
                    self.buildDatabaseButton.tintColor = self.completionColor
                    self.operationProgressLabel.textColor = self.completionColor
                    self.operationProgressLabel.text = "Build All Completed"
                }
            }
            else {
                self.progressView.progress = progressFraction
            }
        })
    }
    
    func showBuildCompletionAlert(operationType: DatabaseOperationType)
    {
        operationProgressLabel.text = "\(DatabaseProgress.databaseOperationTypeToString(operationType)) List Build Completed"
        
        colorLabelForOperationType(operationType)
        
        var alertMessage:String
        
        if operationType == .GenreOperation {
            alertMessage = "Build All Completed"
        }
        else {
            alertMessage = "\(DatabaseProgress.databaseOperationTypeToString(operationType)) List Built"
        }
        
        IToast().showToast(self, alertTitle: "Progress Alert", alertMessage: alertMessage, duration: 2, callersCompletionHandler:nil)
    }

    func colorLabelForOperationType(operationType: DatabaseOperationType) {
        switch operationType {
        case .SongOperation:
            buildingSongsListLabel.textColor = self.completionColor
            break
            
        case .AlbumOperation:
            buildingAlbumsListLabel.textColor = self.completionColor
            break
            
        case .ArtistOperation:
            buildingArtistsListLabel.textColor = self.completionColor
            break
            
        case .PlaylistOperation:
            buildingPlaylistsListLabel.textColor = self.completionColor
            break
            
        case .GenreOperation:
            buildingGenresListLabel.textColor = self.completionColor
            break
        }
    }
    
    @IBAction func buildDatabaseButtonPressed(sender: AnyObject) {
        let databaseDeletionOperations = DatabaseDeletionOperations()
        databaseDeletionOperations.delegate = self
        databaseBuildQueue.addOperation(databaseDeletionOperations)
        
        let songDatabaseOperations = SongDatabaseOperations()
        songDatabaseOperations.delegate = self
        databaseBuildQueue.addOperation(songDatabaseOperations)
        
        let albumDatabaseOperations = AlbumDatabaseOperations()
        albumDatabaseOperations.delegate = self
        databaseBuildQueue.addOperation(albumDatabaseOperations)
        
        let artistDatabaseOperations = ArtistDatabaseOperations()
        artistDatabaseOperations.delegate = self
        databaseBuildQueue.addOperation(artistDatabaseOperations)
        
        let playlistDatabaseOperations = PlaylistDatabaseOperations()
        playlistDatabaseOperations.delegate = self
        databaseBuildQueue.addOperation(playlistDatabaseOperations)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
