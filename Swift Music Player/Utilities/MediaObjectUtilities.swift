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
    class func titleAndArtistStringForMediaItem(mediaItem: MPMediaItem) -> String {
        return "title: \(mediaItem.title) and artist: \(mediaItem.artist)"
    }
    
    class func titleAndArtistStringForSong(song: Song) -> String {
        return "title: \(song.summary.title) and artist: \(song.summary.artistName)"
    }
    
    class func titleAndArtistStringForAlbum(album: Album) -> String {
        return "title: \(album.summary.title) and artist: \(album.summary.artistName)"
    }
    
    class func titleArtistLastPlayedTimeAndPersistentIDStringForSong(song: Song) -> String {
        return "title: \(song.summary.title) artist: \(song.summary.artistName) lastPlayedTime: \(DateTimeUtilities.timeIntervalToString(song.summary.lastPlayedTime)) persistentID: \(song.summary.persistentID)"
    }
    
    class func titleArtistLastPlayedTimeAndPersistentKeyStringForSong(song: Song) -> String {
        return "title: \(song.summary.title) artist: \(song.summary.artistName) lastPlayedTime: \(DateTimeUtilities.timeIntervalToString(song.summary.lastPlayedTime)) persistentKey: \(song.summary.persistentKey)"
    }
    
    class func anyObjectToStringOrEmptyString(anyObject: AnyObject?) -> String {
        if anyObject != nil {
            if let anyString = anyObject as? String {
                return anyString
            }
        }
        return ""
    }
    
    class func anyObjectToNSNumber(anyObject: AnyObject?, inout numberValue:NSNumber) -> Bool {
        if anyObject != nil {
            if let anyObjectNumber = anyObject as? NSNumber {
                numberValue = anyObjectNumber
                return true
            }
        }
        return false
    }
    
    class func removeLeadingArticles(inputString: String) -> String {
        var returnValue: String
        let inputStringLength = inputString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if inputStringLength >= 4 {
            returnValue = inputString.stringByReplacingOccurrencesOfString("The ", withString: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.startIndex.advancedBy(4)))
            
            if returnValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != inputStringLength {
                return returnValue
            }
        }
        
        if inputStringLength >= 3 {
            returnValue = inputString.stringByReplacingOccurrencesOfString("An ", withString: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.startIndex.advancedBy(3)))
            
            if returnValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != inputStringLength {
                return returnValue
            }
        }
        
        if inputStringLength >= 2 {
            returnValue = inputString.stringByReplacingOccurrencesOfString("A ", withString: "", options: [], range: Range<String.Index>(inputString.startIndex..<inputString.startIndex.advancedBy(2)))
            
            if returnValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != inputStringLength {
                return returnValue
            }
        }
        
        if inputStringLength >= 1 {
            returnValue = inputString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "~\"'#(."))
            return returnValue
        }
        
        return inputString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
    }
    
    
    class func returnMediaObjectStrippedString(inputString: String) -> String {
        var trimmedString = removeLeadingArticles(inputString)
        
        if (trimmedString != "")
        {
            let accentedCharacter = trimmedString.substringToIndex(inputString.startIndex.advancedBy(1)).uppercaseString
            var strippedString = accentedCharacter.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale:NSLocale(localeIdentifier: "en_us"))
            
            if stringIsNumeric(strippedString) {
                strippedString = "_" + trimmedString
            }
            else
            {
                trimmedString = trimmedString.substringFromIndex(inputString.startIndex.advancedBy(1))
                strippedString = strippedString.stringByAppendingString(trimmedString)
            }
            
            return strippedString.uppercaseString
        }
        return ""
    }
    
    class func returnMediaObjectIndexCharacter(inputString: String) -> String {
        if inputString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let accentedCharacter = inputString.substringToIndex(inputString.startIndex.advancedBy(1)).uppercaseString
            var indexCharacter = accentedCharacter.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale:NSLocale(localeIdentifier: "en_us"))
            
            if stringIsNumeric(indexCharacter) {
                indexCharacter = "_"
            }
            
            return indexCharacter
        }
        return ""
    }
    
    class func stringIsNumeric(inputString: String) -> Bool
    {
        let unwantedCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return inputString.rangeOfCharacterFromSet(unwantedCharacters, options: [], range: nil) == nil
    }
    
}