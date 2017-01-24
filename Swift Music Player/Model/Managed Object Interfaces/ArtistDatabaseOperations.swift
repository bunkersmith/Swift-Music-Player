//
//  ArtistDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class ArtistDatabaseOperations: NSObject {

    weak var delegate:DatabaseProgressDelegate?

    func start(databaseInterface: DatabaseInterface) {
        let startTime = MillisecondTimer.currentTickCount()
        
        var progressFraction: Float
        
        let artistsQuery = MPMediaQuery.artists()
        artistsQuery.groupingType = .albumArtist
    
        let artistFactory = ArtistFactory()
        
        guard let artistsCollection:[MPMediaItemCollection] = artistsQuery.collections else {
            Logger.writeToLogFile("Artists query failed")
            delegate?.progressUpdate(1.0, operationType: .artistOperation)
            return
        }
        
        var artistIndex = 0
        
        for artistCollection:MPMediaItemCollection in artistsCollection
        {
            artistFactory.processArtistMediaItem(artistCollection.representativeItem!, databaseInterface:databaseInterface)
            
            if artistIndex % 10 == 0 || artistIndex == artistsCollection.count - 1 {
                progressFraction = Float(artistIndex + 1) / Float(artistsCollection.count)
                self.delegate?.progressUpdate(progressFraction, operationType: .artistOperation)
            }
            
            artistIndex += 1
        }
        
        let artistCount = databaseInterface.countOfEntitiesOfType("Artist", predicate: nil)
        Logger.writeToLogFile("Artist List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(artistCount) artists")
    }
}
