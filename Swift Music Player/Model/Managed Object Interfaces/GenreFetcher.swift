//
//  GenreFetcher.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import MediaPlayer

class GenreFetcher {
    
    class func fetchGenreSummaryWithPersistentID(_ persistentID: UInt64, databaseInterface: DatabaseInterface) -> GenreSummary? {
        let genreSummaries:Array<GenreSummary> = databaseInterface.entitiesOfType("GenreSummary", predicate: NSPredicate(format: "persistentID == %llu", persistentID)) as! Array<GenreSummary>
        if genreSummaries.count == 1 {
            return genreSummaries.first
        }
        
        return nil
    }
    
    class func fetchGenreSongsWithGenreName(_ genreName:String, databaseInterface:DatabaseInterface) -> Array<Song>
    {
        if let genreSongs = databaseInterface.entitiesOfType("Song", predicate: NSPredicate(format:"genreName == %@", genreName)) as? Array<Song> {
            return genreSongs
        }
        Logger.writeToLogFile("Returning zero songs for genre name \(genreName)")
        return Array<Song>()
    }
    
}
