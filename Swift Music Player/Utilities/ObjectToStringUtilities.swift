//
//  ObjectToStringUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import MessageUI

class ObjectToStringUtilities {
    class func imageOrientationToString(orientation:UIImageOrientation) -> String {
        switch (orientation) {
        case .Down:
            return "UIImageOrientationDown";
            
        case .DownMirrored:
            return "UIImageOrientationDownMirrored";
            
        case .Left:
            return "UIImageOrientationLeft";
            
        case .LeftMirrored:
            return "UIImageOrientationLeftMirrored";
            
        case .Right:
            return "UIImageOrientationRight";
            
        case .RightMirrored:
            return "UIImageOrientationRigheMirrored";
            
        case .Up:
            return "UIImageOrientationUp";
            
        case .UpMirrored:
            return "UIImageOrientationUpMirrored";
        }
    }
    
    class func stringFromCGSize(size: CGSize) -> String {
        return String(format: "%.2f, %.2f", size.width, size.height)
    }
    
    class func stringFromCGPoint(point: CGPoint) -> String {
        return String(format: "%.2f, %.2f", point.x, point.y)
    }
    
    class func stringFromCGRect(rect: CGRect) -> String {
        let returnValue = String(format: "origin = %.2f, %.2f", rect.origin.x, rect.origin.y)
        return returnValue + String(format: "\nsize = %.2f, %.2f", rect.size.width, rect.size.height)
    }
    
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
    
    class func eventTypeToString(eventType: UIEventType) -> String
    {
        var returnValue = ""
        
        switch (eventType)
        {
        case .Touches:
            returnValue = "UIEventTypeTouches"
            break
            
        case .Motion:
            returnValue = "UIEventTypeMotion"
            break
            
        case .RemoteControl:
            returnValue = "UIEventTypeRemoteControl"
            break
            
        default:
            returnValue = "Unknown"
            break
        }
        
        return returnValue
    }
    
    class func eventSubtypeToString(eventSubtype: UIEventSubtype) -> String
    {
        var returnValue = ""
        
        switch (eventSubtype)
        {
        case .None:
            returnValue = "UIEventSubtypeNone"
            break
            
        case .MotionShake:
            returnValue = "UIEventSubtypeMotionShake"
            break
            
        case .RemoteControlPlay:
            returnValue = "UIEventSubtypeRemoteControlPlay"
            break
            
        case .RemoteControlPause:
            returnValue = "UIEventSubtypeRemoteControlPause"
            break
            
        case .RemoteControlStop:
            returnValue = "UIEventSubtypeRemoteControlStop"
            break
            
        case .RemoteControlTogglePlayPause:
            returnValue = "UIEventSubtypeRemoteControlTogglePlayPause"
            break
            
        case .RemoteControlNextTrack:
            returnValue = "UIEventSubtypeRemoteControlNextTrack"
            break
            
        case .RemoteControlPreviousTrack:
            returnValue = "UIEventSubtypeRemoteControlPreviousTrack"
            break
            
        case .RemoteControlBeginSeekingBackward:
            returnValue = "UIEventSubtypeRemoteControlBeginSeekingBackward"
            break
            
        case .RemoteControlEndSeekingBackward:
            returnValue = "UIEventSubtypeRemoteControlEndSeekingBackward"
            break
            
        case .RemoteControlBeginSeekingForward:
            returnValue = "UIEventSubtypeRemoteControlBeginSeekingForward"
            break
            
        case .RemoteControlEndSeekingForward:
            returnValue = "UIEventSubtypeRemoteControlEndSeekingForward"
            break
        }
        
        return returnValue
    }
    
    class func fetchedResultsChangeTypeToString(fetchedResultsChangeType: NSFetchedResultsChangeType) -> String {
        var returnValue = ""
        
        switch (fetchedResultsChangeType) {
        case .Insert:
            returnValue = "NSFetchedResultsChangeInsert"
            break
        case .Delete:
            returnValue = "NSFetchedResultsChangeDelete"
            break
        case .Move:
            returnValue = "NSFetchedResultsChangeMove"
            break
        case .Update:
            returnValue = "NSFetchedResultsChangeUpdate"
            break
        }
        
        return returnValue
    }
    
    class func mfMailComposeResultToString(result: MFMailComposeResult) -> String {
        var resultString:String
        switch (result.rawValue) {
        case MFMailComposeResultCancelled.rawValue:
            resultString = "Result: Mail sending cancelled"
            break
        case MFMailComposeResultSaved.rawValue:
            resultString = "Result: Mail saved"
            break
        case MFMailComposeResultSent.rawValue:
            resultString = "Result: Mail sent"
            break
        case MFMailComposeResultFailed.rawValue:
            resultString = "Result: Mail sending failed"
            break
        default:
            resultString = "Result: Unknown (mail not sent)"
            break
        }
        return resultString
    }
    
    class func eventTypeAndSubtypeToString(event: UIEvent) -> String {
        return "type = \(eventTypeToString(event.type)) and subtype = \(eventSubtypeToString(event.subtype))"
    }
}
