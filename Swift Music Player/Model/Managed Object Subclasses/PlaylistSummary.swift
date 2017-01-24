//
//  PlaylistSummary.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class PlaylistSummary: NSManagedObject {

    @NSManaged var persistentID: UInt64
    @NSManaged var searchKey: String
    @NSManaged var title: String
    @NSManaged var forPlaylist: Playlist

    override var description: String {
        var returnValue = "***** PLAYLIST SUMMARY *****"
        returnValue = returnValue + "\ntitle: " + title
        returnValue = returnValue + "\nsearchKey: \(searchKey)"
        returnValue = returnValue + "\npersistentID: \(persistentID)"
        return returnValue
    }
}
