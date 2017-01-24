//
//  AlbumSummary.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class AlbumSummary: NSManagedObject {

    @NSManaged var artistName: String
    @NSManaged var indexCharacter: String
    @NSManaged var persistentID: UInt64
    @NSManaged var searchKey: String
    @NSManaged var strippedTitle: String
    @NSManaged var title: String
    @NSManaged var forAlbum: Album

    override var description: String {
        var returnValue = "***** ALBUM SUMMARY *****"
        returnValue = returnValue + "\nartistName: \(artistName)"
        returnValue = returnValue + "\nindexCharacter: \(indexCharacter)"
        returnValue = returnValue + "\nstrippedTitle: (strippedTitle)"
        returnValue = returnValue + "\ntitle: \(title)"
        returnValue = returnValue + "\nsearchKey: \(searchKey)"
        returnValue = returnValue + "\npersistentID: \(persistentID)"
        return returnValue
    }
}
