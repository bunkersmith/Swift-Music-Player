//
//  AlbumDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumDatabaseOperations: NSObject {
    
    weak var delegate:DatabaseProgressDelegate?
    fileprivate var instrumentalAlbums: Array<NSDictionary>!
    
    func start(databaseInterface: DatabaseInterface) {
        let startTime = MillisecondTimer.currentTickCount()
        
        let albumFactory = AlbumFactory()
        
        let userPreferences = UserPreferences()
        instrumentalAlbums = userPreferences.instrumentalAlbums
        
        let albumsQuery = MPMediaQuery.albums()
        
        guard let albumsCollection:[MPMediaItemCollection] = albumsQuery.collections else {
            Logger.writeToLogFile("Albums query failed")
            delegate?.progressUpdate(1.0, operationType: .albumOperation)
            return
        }
        
        var albumIndex: Int = 0
        var progressFraction: Float
        
        for currentMediaCollection:MPMediaItemCollection in albumsCollection
        {
            let albumSongMediaItems = currentMediaCollection.items
            if albumFactory.processAlbumMediaItem(currentMediaCollection.representativeItem!,
                                                  albumSongMediaItems: albumSongMediaItems,
                                                  albumIndex:Int16(albumIndex),
                                                  instrumentalAlbums: instrumentalAlbums,
                                                  databaseInterface: databaseInterface) {
                databaseInterface.saveContext()
            }
            
            if albumIndex % 10 == 0 || albumIndex == albumsCollection.count - 1 {
                progressFraction = Float(albumIndex + 1) / Float(albumsCollection.count)
                delegate?.progressUpdate(progressFraction, operationType: .albumOperation)
            }
            
            albumIndex+=1
        }
        
        let albumCount = databaseInterface.countOfEntitiesOfType("Album", predicate: nil)
        Logger.writeToLogFile("Album List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(albumCount) albums")
        //Logger.writeToLogFile("instrumentalAlbumCount = \(instrumentalAlbumCount)")
        
        //[self performSelectorOnMainThread:@selector(sendAlbumsTableNeedsReloadNotification) withObject:nil waitUntilDone:NO]
    }
}
