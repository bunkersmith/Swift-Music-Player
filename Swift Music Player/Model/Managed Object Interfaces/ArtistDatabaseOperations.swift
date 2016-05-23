//
//  ArtistDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class ArtistDatabaseOperations: NSOperation {

    var delegate:DatabaseProgressDelegate?

    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        var progressFraction: Float
        
        let artistsQuery = MPMediaQuery.artistsQuery()
        artistsQuery.groupingType = .AlbumArtist
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        let artistFactory = ArtistFactory()
        
        if let artistsCollection:[MPMediaItemCollection]? = artistsQuery.collections  {
            var artistIndex = 0
            
            for artistCollection:MPMediaItemCollection in artistsCollection!
            {
                artistFactory.processArtistMediaItem(artistCollection.representativeItem!, databaseInterface:databaseInterface)
                
                if artistIndex % 10 == 0 || artistIndex == artistsCollection!.count - 1 {
                    progressFraction = Float(artistIndex + 1) / Float(artistsCollection!.count)
                    delegate?.progressUpdate(progressFraction, operationType: .ArtistOperation)
                }
                
                artistIndex += 1
            }
        }
        else {
            Logger.writeToLogFile("Artists query failed")
        }
        
        let artistCount = databaseInterface.countOfEntitiesOfType("Artist", predicate: nil)
        Logger.writeToLogFile("Artist List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(artistCount) artists")
    }
}
