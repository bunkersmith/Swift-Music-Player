//
//  DatabaseProgress.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

enum DatabaseOperationType {
    case SongOperation
    case AlbumOperation
    case ArtistOperation
    case PlaylistOperation
    case GenreOperation
}

protocol DatabaseProgressDelegate {
    func progressUpdate(progressFraction:Float, operationType:DatabaseOperationType)
}

class DatabaseProgress {
    class func databaseOperationTypeToString(operationType:DatabaseOperationType) -> String {
        var returnValue:String = "Unknown"
        
        switch operationType {
            case .SongOperation:
                returnValue = "Song"
            break
            
            case .AlbumOperation:
                returnValue = "Album"
            break
            
            case .ArtistOperation:
                returnValue = "Artist"
            break
            
            case .PlaylistOperation:
                returnValue = "Playlist"
            break
            
            case .GenreOperation:
                returnValue = "Genre"
            break
        }
        
        return returnValue
    }
}
