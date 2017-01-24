//
//  MediaObjectUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import MediaPlayer

class MediaObjectUtilities {
    class func titleAndArtistStringForMediaItem(_ mediaItem: MPMediaItem) -> String {
        return "title: \(mediaItem.title) and artist: \(mediaItem.artist)"
    }
    
    class func titleAndArtistStringForSong(_ song: Song) -> String {
        return "title: \(song.summary.title) and artist: \(song.summary.artistName)"
    }
    
    class func titleAndArtistStringForAlbum(_ album: Album) -> String {
        return "title: \(album.summary.title) and artist: \(album.summary.artistName)"
    }
    
    class func titleArtistLastPlayedTimeAndPersistentIDStringForSong(_ song: Song) -> String {
        return "title: \(song.summary.title) artist: \(song.summary.artistName) lastPlayedTime: \(DateTimeUtilities.timeIntervalToString(song.summary.lastPlayedTime)) persistentID: \(song.summary.persistentID)"
    }
    
    class func titleArtistLastPlayedTimeAndPersistentKeyStringForSong(_ song: Song) -> String {
        return "title: \(song.summary.title) artist: \(song.summary.artistName) lastPlayedTime: \(DateTimeUtilities.timeIntervalToString(song.summary.lastPlayedTime)) persistentKey: \(song.summary.persistentKey)"
    }
    
    class func anyObjectToStringOrEmptyString(_ anyObject: AnyObject?) -> String {
        if anyObject != nil {
            if let anyString = anyObject as? String {
                return anyString
            }
        }
        return ""
    }
    
    class func anyObjectToNSNumber(_ anyObject: AnyObject?, numberValue:inout NSNumber) -> Bool {
        if anyObject != nil {
            if let anyObjectNumber = anyObject as? NSNumber {
                numberValue = anyObjectNumber
                return true
            }
        }
        return false
    }
    
    class func removeLeadingArticles(_ inputString: String) -> String {
        var returnValue: String
        let inputStringLength = inputString.lengthOfBytes(using: String.Encoding.utf8)
        
        // Logger.logDetails(msg: "Entered")
        // Logger.writeToLogFile("inputString = *\(inputString)*")

        if inputStringLength >= 4 {
            returnValue = inputString.replacingOccurrences(of: "The ", with: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.characters.index(inputString.startIndex, offsetBy: 4)))
            
            if returnValue.lengthOfBytes(using: String.Encoding.utf8) != inputStringLength {
                //Logger.logDetails(msg:"Returning *\(returnValue)*")
                return returnValue
            }
        }
        
        if inputStringLength >= 3 {
            returnValue = inputString.replacingOccurrences(of: "An ", with: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.characters.index(inputString.startIndex, offsetBy: 3)))
            
            if returnValue.lengthOfBytes(using: String.Encoding.utf8) != inputStringLength {
                // Logger.logDetails(msg:"Returning *\(returnValue)*")
                return returnValue
            }
        }
        
        if inputStringLength >= 2 {
            returnValue = inputString.replacingOccurrences(of: "A ", with: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.characters.index(inputString.startIndex, offsetBy: 2)))
            
            if returnValue.lengthOfBytes(using: String.Encoding.utf8) != inputStringLength {
                // Logger.logDetails(msg: "Returning *\(returnValue)*")
                return returnValue
            }
        }
        
        if inputStringLength >= 1 {
            returnValue = inputString.trimmingCharacters(in: CharacterSet(charactersIn: "~\"'#(."))
            // Logger.logDetails(msg: "Returning *\(returnValue)*")
            return returnValue
        }
        
        returnValue = inputString.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        // Logger.logDetails(msg: "Returning *\(returnValue)*")
        return returnValue
    }
    
    
    class func returnMediaObjectStrippedString(_ inputString: String) -> String {
        var trimmedString = removeLeadingArticles(inputString)
        
        // Logger.logDetails(msg: "Entered")
        // Logger.writeToLogFile("inputString = *\(inputString)*")
        // Logger.writeToLogFile("trimmedString = *\(trimmedString)*")
        
        if trimmedString != ""
        {
            var strippedString:String
            
            if trimmedString.characters.count == 1 {
                strippedString = trimmedString
            } else {
                let accentedCharacter = String(trimmedString[trimmedString.index(trimmedString.startIndex, offsetBy: 0)]).uppercased()
                strippedString = accentedCharacter.folding(options: .diacriticInsensitive, locale:Locale(identifier: "en_us"))
            }
            
            if stringIsNumeric(strippedString) {
                // Add a leading underscore to numeric titles, so that they sort into the correct section
                strippedString = "_" + trimmedString
            }
            else
            {
                trimmedString = trimmedString.substring(from: inputString.characters.index(inputString.startIndex, offsetBy: 1))
                strippedString = strippedString + trimmedString
            }
            
            // Logger.logDetails(msg: "Returning *\(strippedString)*")
            return strippedString.uppercased()
        }
        // Logger.logDetails(msg: "Returning an empty string")
        return ""
    }
    
    class func returnMediaObjectIndexCharacter(_ inputString: String) -> String {
        // Logger.logDetails(msg: "Entered")
        // Logger.writeToLogFile("inputString = *\(inputString)*")
        
        if inputString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            var indexCharacter:String
            
            if inputString.characters.count == 1 {
                indexCharacter = inputString
            } else {
                let accentedCharacter = String(inputString[inputString.index(inputString.startIndex, offsetBy: 0)]).uppercased()
                indexCharacter = accentedCharacter.folding(options: .diacriticInsensitive, locale:Locale(identifier: "en_us"))
            }
            
            if stringIsNumeric(indexCharacter) {
                indexCharacter = "_"
            }
            
            // Logger.logDetails(msg: "Returning \(indexCharacter)")
            return indexCharacter
        }
        // Logger.logDetails(msg: "Returning an empty string")
        return ""
    }
    
    class func stringIsNumeric(_ inputString: String) -> Bool
    {
        let unwantedCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return inputString.rangeOfCharacter(from: unwantedCharacters, options: [], range: nil) == nil
    }
    
}
