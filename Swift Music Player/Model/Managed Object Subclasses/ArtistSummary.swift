//
//  ArtistSummary.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class ArtistSummary: NSManagedObject {

    @NSManaged var indexCharacter: String
    @NSManaged var name: String
    @NSManaged var persistentID: UInt64
    @NSManaged var searchKey: String
    @NSManaged var strippedName: String
    @NSManaged var forArtist: Artist

    override var description: String {
        var returnValue = "***** ARTIST SUMMARY *****"
        returnValue = returnValue + "\nindexCharacter: " + indexCharacter
        returnValue = returnValue + "\nname: " + name
        returnValue = returnValue + "\nstrippedName: " + strippedName
        returnValue = returnValue + "\nsearchKey: \(searchKey)"
        returnValue = returnValue + "\npersistentID: \(persistentID)"
        return returnValue
    }
}
