//
//  DatabaseProgress.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

enum DatabaseOperationType {
    case songOperation
    case albumOperation
    case artistOperation
    case playlistOperation
    case genreOperation
    
    static let allValues = [songOperation,
                            albumOperation,
                            artistOperation,
                            playlistOperation,
                            genreOperation]
}

protocol DatabaseProgressDelegate: class {
    func progressUpdate(_ progressFraction:Float, operationType:DatabaseOperationType)
}

class DatabaseProgress {
    class func databaseOperationTypeToString(_ operationType:DatabaseOperationType) -> String {
        var returnValue:String = "Unknown"
        
        switch operationType {
            case .songOperation:
                returnValue = "Song"
            break
            
            case .albumOperation:
                returnValue = "Album"
            break
            
            case .artistOperation:
                returnValue = "Artist"
            break
            
            case .playlistOperation:
                returnValue = "Playlist"
            break
            
            case .genreOperation:
                returnValue = "Genre"
            break
        }
        
        return returnValue
    }
}
