//
//  DatabaseViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class DatabaseViewController: PortraitViewController, DatabaseProgressDelegate, DeletionProgressDelegate {

    @IBOutlet weak var buildDatabaseButton: UIButton!
    @IBOutlet weak var buildingSongsListLabel: UILabel!
    @IBOutlet weak var buildingAlbumsListLabel: UILabel!
    @IBOutlet weak var buildingArtistsListLabel: UILabel!
    @IBOutlet weak var buildingPlaylistsListLabel: UILabel!
    @IBOutlet weak var buildingGenresListLabel: UILabel!
    @IBOutlet weak var operationProgressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    fileprivate let databaseManager = DatabaseManager.instance
    
    
    lazy var progressColor: UIColor = {
        return UIColor(red:0.0, green:0.75, blue:0.0, alpha:1.0)
    }()
    
    lazy var completionColor: UIColor = {
        return UIColor.green
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func deletionProgressUpdate(_ progressLabelText: String, progressViewAlpha: CGFloat) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.operationProgressLabel.text = progressLabelText
            self.progressView.alpha = progressViewAlpha
        })
    }

    func progressUpdate(_ progressFraction:Float, operationType:DatabaseOperationType) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.progressView.alpha = 1.0
            self.operationProgressLabel.text = DatabaseProgress.databaseOperationTypeToString(operationType) + " Addition Progress"

            if progressFraction == 1.0 {
                self.progressView.progress = 0.0
                self.showBuildCompletionAlert(operationType)
                if operationType == .genreOperation {
                    self.databaseManager.databaseBuildInProgress = false
                    self.operationProgressLabel.textColor = self.completionColor
                    self.operationProgressLabel.text = "Build All Completed"
                }
            }
            else {
                self.progressView.progress = progressFraction
            }
        })
    }
    
    func showBuildCompletionAlert(_ operationType: DatabaseOperationType)
    {
        operationProgressLabel.text = "\(DatabaseProgress.databaseOperationTypeToString(operationType)) List Build Completed"
        
        let label = labelForOperationType(operationType)
        label.alpha = 1.0
    }

    func labelForOperationType(_ operationType: DatabaseOperationType) -> UILabel {
        switch operationType {
        case .songOperation:
            return buildingSongsListLabel
            
        case .albumOperation:
            return buildingAlbumsListLabel
            
        case .artistOperation:
            return buildingArtistsListLabel
            
        case .playlistOperation:
            return buildingPlaylistsListLabel
            
        case .genreOperation:
            return buildingGenresListLabel
        }
    }
    
    func hideAllLabels() {
        for operationType in DatabaseOperationType.allValues {
            let label = labelForOperationType(operationType)
            label.alpha = 0.0
        }
    }
    
    @IBAction func buildDatabaseButtonPressed(_ sender: AnyObject) {
        operationProgressLabel.textColor = progressColor
        hideAllLabels()
        
        databaseManager.databaseBuildInProgress = true

        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(concurrencyType: .privateQueueConcurrencyType)
        
        SongFetcher.fetchAllPlayedSongs { (songDictionaries) in
            Logger.logDetails(msg: "\(songDictionaries)")
            
            databaseInterface.performInBackground {
                let databaseDeletionOperations = DatabaseDeletionOperations()
                databaseDeletionOperations.delegate = self
                databaseDeletionOperations.start(databaseInterface: databaseInterface)
                
                let songDatabaseOperations = SongDatabaseOperations()
                songDatabaseOperations.delegate = self
                songDatabaseOperations.start(databaseInterface: databaseInterface, playedSongs:songDictionaries)
                
                let albumDatabaseOperations = AlbumDatabaseOperations()
                albumDatabaseOperations.delegate = self
                albumDatabaseOperations.start(databaseInterface: databaseInterface)
                
                let artistDatabaseOperations = ArtistDatabaseOperations()
                artistDatabaseOperations.delegate = self
                artistDatabaseOperations.start(databaseInterface: databaseInterface)
                
                let playlistDatabaseOperations = PlaylistDatabaseOperations()
                playlistDatabaseOperations.delegate = self
                playlistDatabaseOperations.start(databaseInterface: databaseInterface)
                
                let genreDatabaseOperations = GenreDatabaseOperations()
                genreDatabaseOperations.delegate = self
                genreDatabaseOperations.start(databaseInterface: databaseInterface)
                
                Logger.writeToLogFile("Total Database Build Time: \(MillisecondTimer.secondsSince(startTime))")
            }
        }
    }
    
}
