//
//  DateTimeUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class DateTimeUtilities {
    class func dateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(date)
    }
    
    class func timeIntervalToString(timeInterval: NSTimeInterval) -> String {
        return dateToString(NSDate(timeIntervalSinceReferenceDate: timeInterval))
    }
    
    class func returnStringFromNSDate(date: NSDate?) -> String
    {
        var userVisibleDateTimeString = ""
        
        if date != nil {
            // Convert the date object to a user-visible date string.
            let userVisibleDateFormatter = NSDateFormatter()
            userVisibleDateFormatter.dateStyle = .ShortStyle
            userVisibleDateFormatter.timeStyle = .ShortStyle
            
            userVisibleDateTimeString = userVisibleDateFormatter.stringFromDate(date!)
        }
        
        return userVisibleDateTimeString
    }
    
    class func durationToMinutesString(duration: Double) -> String {
        let minutes = floor(duration / 60.0)
        return String(format: "%.0f", minutes)
    }
    
    class func durationToMinutesAndSecondsString(duration: Double) -> String {
        let seconds = floor(duration % 60.0)
        let minutes = floor(duration / 60.0)
        return String(format: "%.0f:%02.0f", minutes, seconds)
    }
    
    class func returnNowTimeInterval() -> NSTimeInterval {
        let nowDate = NSDate()
        return nowDate.timeIntervalSinceReferenceDate
    }
}
