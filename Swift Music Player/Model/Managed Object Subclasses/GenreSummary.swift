//
//  GenreSummary.swift
//  Swift Music Player
//
//  Created by CarlSmith on 8/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class GenreSummary: NSManagedObject {

    @NSManaged var indexCharacter: String
    @NSManaged var name: String
    @NSManaged var persistentID: UInt64
    @NSManaged var searchKey: String
    @NSManaged var forGenre: Genre

    override var description: String {
        var returnValue = "***** GENRE SUMMARY *****"
        returnValue = returnValue + "\nindexCharacter: " + indexCharacter
        returnValue = returnValue + "\nname: " + name
        returnValue = returnValue + "\nsearchKey: \(searchKey)"
        returnValue = returnValue + "\npersistentID: \(persistentID)"
        return returnValue
    }
}
