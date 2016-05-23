//
//  AlbumDatabaseOperations.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/23/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumDatabaseOperations: NSOperation {
    
    var delegate:DatabaseProgressDelegate?
    private var instrumentalAlbums: Array<NSDictionary>!
    
    override func main() {
        let startTime = MillisecondTimer.currentTickCount()
        
        let albumFactory = AlbumFactory()
        
        let userPreferences = UserPreferences()
        instrumentalAlbums = userPreferences.instrumentalAlbums
        
        let databaseInterface = DatabaseInterface(forMainThread: false)
        
        let albumsQuery = MPMediaQuery.albumsQuery()
        if let albumsCollection:[MPMediaItemCollection]? = albumsQuery.collections {
            
            var albumIndex: Int = 0
            var progressFraction: Float
            
            for currentMediaCollection:MPMediaItemCollection in albumsCollection!
            {
                let albumSongMediaItems = currentMediaCollection.items
                if albumFactory.processAlbumMediaItem(currentMediaCollection.representativeItem!,
                                                      albumSongMediaItems: albumSongMediaItems,
                                                      albumIndex:Int16(albumIndex),
                                                      instrumentalAlbums: instrumentalAlbums,
                                                      databaseInterface: databaseInterface) {
                    databaseInterface.saveContext()
                }
                
                if albumIndex % 10 == 0 || albumIndex == albumsCollection!.count - 1 {
                    progressFraction = Float(albumIndex + 1) / Float(albumsCollection!.count)
                    delegate?.progressUpdate(progressFraction, operationType: .AlbumOperation)
                }
                
                albumIndex+=1
            }
        }
        else {
            Logger.writeToLogFile("Albums query failed")
        }
        
        let albumCount = databaseInterface.countOfEntitiesOfType("Album", predicate: nil)
        Logger.writeToLogFile("Album List Build Time: \(MillisecondTimer.secondsSince(startTime)) for \(albumCount) albums")
        //Logger.writeToLogFile("instrumentalAlbumCount = \(instrumentalAlbumCount)")
        
        //[self performSelectorOnMainThread:@selector(sendAlbumsTableNeedsReloadNotification) withObject:nil waitUntilDone:NO]
    }
}
