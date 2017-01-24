//
//  ProcessTextFile.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 9/28/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class ProcessTextFile: NSObject {
    
    var _fileName:String!
    var _fileContent:String!
    var _allLines:[String]!
    
    func openFile(fileName: String) -> Bool
    {
        _fileName = fileName
        _allLines = []
   
        do {
            try _fileContent = String(contentsOfFile:_fileName, encoding:String.Encoding.utf8)
        } catch let error as NSError {
            Logger.writeToLogFile("Error reading file named \(fileName): \(error)")
            return false
        }
        
        let allLinesIncludingBlankOnes:[String] = _fileContent.components(separatedBy: NSCharacterSet.newlines)
        
        for line in allLinesIncludingBlankOnes {
            if line != "" {
                _allLines.append(line)
            }
        }
        return true
    }
    
    func lineAtIndex(index: NSInteger) -> String {
        var returnValue:String
    
        if index < _allLines.count {
            returnValue = _allLines[index]
        }
        else {
            returnValue = ""
        }
        
        return returnValue
    }
    
    func linesInFile() -> Int
    {
        return _allLines.count
    }

}
