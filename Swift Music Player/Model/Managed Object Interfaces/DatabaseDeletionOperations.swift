//
//  DatabaseDeletionOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

protocol DeletionProgressDelegate {
    func deletionProgressUpdate(progressLabelText: String, progressViewAlpha: CGFloat)
}

class DatabaseDeletionOperations: NSOperation {
    var delegate: DeletionProgressDelegate?
    
    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        deletePhase(databaseInterface, entityName: "Song")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "SongSummary")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "Album")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "AlbumSummary")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "Artist")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "ArtistSummary")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "Playlist")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "PlaylistSummary")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "Genre")
        if cancelled { return }
        deletePhase(databaseInterface, entityName: "GenreSummary")
        
        Logger.writeToLogFile("Database Deletion Time: \(MillisecondTimer.secondsSince(startTime))")
    }
    
    func deletePhase(databaseInterface: DatabaseInterface, entityName:String)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var progressLabelText: String
            if entityName.containsString("ummary") {
                let substr = entityName.substringToIndex(entityName.endIndex.predecessor())
                progressLabelText = "Deleting " + substr + "ies"
            }
            else {
                progressLabelText = "Deleting " + entityName + "s"
            }
            self.delegate?.deletionProgressUpdate(progressLabelText, progressViewAlpha: 0.0)
        })
        
        databaseInterface.deleteAllObjectsWithEntityName(entityName)
    }
}
