//
//  DatabaseDeletionOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

protocol DeletionProgressDelegate: class {
    func deletionProgressUpdate(_ progressLabelText: String, progressViewAlpha: CGFloat)
}

class DatabaseDeletionOperations: NSObject {
    weak var delegate: DeletionProgressDelegate?
    
    func start(databaseInterface: DatabaseInterface) {
        let startTime = MillisecondTimer.currentTickCount()
        
        deletePhase(databaseInterface, entityName: "Song")
        deletePhase(databaseInterface, entityName: "SongSummary")
        deletePhase(databaseInterface, entityName: "Album")
        deletePhase(databaseInterface, entityName: "AlbumSummary")
        deletePhase(databaseInterface, entityName: "Artist")
        deletePhase(databaseInterface, entityName: "ArtistSummary")
        deletePhase(databaseInterface, entityName: "Playlist")
        deletePhase(databaseInterface, entityName: "PlaylistSummary")
        deletePhase(databaseInterface, entityName: "Genre")
        deletePhase(databaseInterface, entityName: "GenreSummary")
        
        Logger.writeToLogFile("Database Deletion Time: \(MillisecondTimer.secondsSince(startTime))")
    }
    
    func deletePhase(_ databaseInterface: DatabaseInterface, entityName:String)
    {
        var progressLabelText: String
        if entityName.contains("ummary") {
            let substr = entityName.substring(to: entityName.characters.index(before: entityName.endIndex))
            progressLabelText = "Deleting " + substr + "ies"
        }
        else {
            progressLabelText = "Deleting " + entityName + "s"
        }
        delegate?.deletionProgressUpdate(progressLabelText, progressViewAlpha: 0.0)
        
        databaseInterface.deleteAllObjectsWithEntityName(entityName)
    }
}
