//
//  GenreDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class GenreDatabaseOperations: NSOperation {
    
    var delegate:DatabaseProgressDelegate?

    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        let genreFactory = GenreFactory()
        
        let genresQuery = MPMediaQuery.genresQuery()
        if let genresCollection:[MPMediaItemCollection]? = genresQuery.collections {
            var genreIndex = 0
            var progressFraction:Float
            
            for mediaCollection:MPMediaItemCollection in genresCollection! {
                
                if genreFactory.processGenreMediaItem(mediaCollection.representativeItem!, genreMediaCollection: mediaCollection, databaseInterface: databaseInterface) {
                    databaseInterface.saveContext()
                }
                
                if genreIndex % 10 == 0 || genreIndex == genresCollection!.count - 1 {
                    progressFraction = Float(genreIndex + 1) / Float(genresCollection!.count)
                    delegate?.progressUpdate(progressFraction, operationType: .GenreOperation)
                }
                
                genreIndex += 1
            }
        }
        else {
            Logger.writeToLogFile("Genre collections fech failed")
        }
        
        let genreCount = databaseInterface.countOfEntitiesOfType("Genre", predicate: nil)
        Logger.writeToLogFile("Genre List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(genreCount) genres")
    }
}
