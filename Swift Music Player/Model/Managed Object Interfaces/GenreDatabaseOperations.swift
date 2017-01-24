//
//  GenreDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class GenreDatabaseOperations: NSObject {
    
    weak var delegate:DatabaseProgressDelegate?

    func start(databaseInterface: DatabaseInterface) {
        let startTime = MillisecondTimer.currentTickCount()
        
        let genreFactory = GenreFactory()
        
        let genresQuery = MPMediaQuery.genres()
        guard let genresCollection:[MPMediaItemCollection] = genresQuery.collections else {
            Logger.writeToLogFile("Genre collections fech failed")
            delegate?.progressUpdate(1.0, operationType: .genreOperation)
            return
        }
        
        var genreIndex = 0
        var progressFraction:Float
        
        for mediaCollection:MPMediaItemCollection in genresCollection {
            if genreFactory.processGenreMediaItem(mediaCollection.representativeItem!, genreMediaCollection: mediaCollection, databaseInterface: databaseInterface) {
                databaseInterface.saveContext()
            }
            
            if genreIndex % 10 == 0 || genreIndex == genresCollection.count - 1 {
                progressFraction = Float(genreIndex + 1) / Float(genresCollection.count)
                delegate?.progressUpdate(progressFraction, operationType: .genreOperation)
            }
            
            genreIndex += 1
        }
        
        let genreCount = databaseInterface.countOfEntitiesOfType("Genre", predicate: nil)
        Logger.writeToLogFile("Genre List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(genreCount) genres")
    }
}
