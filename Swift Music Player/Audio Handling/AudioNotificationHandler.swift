//
//  AudioNotificationHandler.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import AVFoundation

class AudioNotificationHandler: NSObject {
    
    private var shouldResumeAudio:Bool = false

    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(routeChanged(_:)), name: AVAudioSessionRouteChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(audioInterrupted(_:)), name:AVAudioSessionInterruptionNotification, object:nil)
        notificationCenter.addObserver(self, selector:#selector(mediaServicesReset(_:)), name:AVAudioSessionMediaServicesWereResetNotification, object:nil)
    }
    
    func removeNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: AVAudioSessionRouteChangeNotification, object: nil)
        notificationCenter.removeObserver(self, name:AVAudioSessionInterruptionNotification, object:nil)
        notificationCenter.removeObserver(self, name:AVAudioSessionMediaServicesWereResetNotification, object:nil)
    }

    func mediaServicesReset(notification: NSNotification)
    {
        Logger.writeToLogFile("\(#function) called with notification = \(notification)")
    }
    
    func audioInterrupted(notification: NSNotification)
    {
        //Logger.writeToLogFile("\(#function) called with notification = \(notification)")
        
        if let userInfo:[NSObject:AnyObject] = notification.userInfo {
            if let interruptionTypeNumber:NSNumber = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber {
                let interruptionTypeInteger = interruptionTypeNumber.unsignedLongValue
                
                //Logger.writeToLogFile("interruptionTypeInteger = \(interruptionTypeInteger)")
                //Logger.writeToLogFile("AVAudioSessionInterruptionType.Began.rawValue = \(AVAudioSessionInterruptionType.Began.rawValue)")
                //Logger.writeToLogFile("AVAudioSessionInterruptionType.Ended.rawValue = \(AVAudioSessionInterruptionType.Ended.rawValue)")
                
                //GlobalVars *globalVarsPtr = [GlobalVars sharedGlobalVars]
                if interruptionTypeInteger == AVAudioSessionInterruptionType.Began.rawValue {
                    shouldResumeAudio = true // SongPlayer.instance.isAudioPlaying()
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        Logger.writeToLogFile("AVSessionManager.audioInterrupted (Began case) sending Swift-Music-Player.updatePlayPauseButton notification (iOS pauses the audio automatically)")
                        // Audio is paused automatically, so update the pause button
                        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.updatePlayPauseButton", object:self, userInfo:["isPlaying": NSNumber(bool: false)])
                    })
                }
                else {
                    if interruptionTypeInteger == AVAudioSessionInterruptionType.Ended.rawValue {
                        if shouldResumeAudio {
                            shouldResumeAudio = false
                            if let interruptionOptionsNumber:NSNumber = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber {
                                let interruptionOptionsInteger = interruptionOptionsNumber.unsignedLongValue
                                
                                //Logger.writeToLogFile("interruptionOptionsInteger = \(interruptionOptionsInteger)")
                                //Logger.writeToLogFile("AVAudioSessionInterruptionOptions.OptionShouldResume.rawValue = \(AVAudioSessionInterruptionOptions.ShouldResume.rawValue)")
                                
                                if interruptionOptionsInteger == AVAudioSessionInterruptionOptions.ShouldResume.rawValue
                                {
                                    let restartTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2) * Int64(NSEC_PER_SEC))
                                    
                                    dispatch_after(restartTime, dispatch_get_global_queue(0, 0), { () -> Void in
                                        // Resume the audio and update the play button
                                        Logger.writeToLogFile("AVSessionManager.audioInterrupted sending Swift-Music-Player.playAudio notification")
                                        Logger.writeToLogFile("AVSessionManager.audioInterrupted (Ended case) sending Swift-Music-Player.updatePlayPauseButton notification")
                                        
                                        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.playAudio", object:self)
                                        NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.updatePlayPauseButton", object:self, userInfo:["isPlaying": NSNumber(bool: true)])
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Logger.writeToLogFile("Leaving \(#function)")
    }
    
    func routeChanged(notification: NSNotification)
    {
        Logger.writeToLogFile("\(#function) called with notification = \(notification)")
        
        if let userInfo:[NSObject:AnyObject] = notification.userInfo {
            if let previousRoute:AVAudioSessionRouteDescription = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                if let routeChangeReasonNumber:NSNumber = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber {
                    let routeChangeReasonInteger = routeChangeReasonNumber.unsignedLongValue
                    if previousRoute.outputs.count > 0 {
                        if let outputPort:AVAudioSessionPortDescription = previousRoute.outputs.first {
                            if (outputPort.portType == AVAudioSessionPortHeadphones || outputPort.portType == AVAudioSessionPortBluetoothA2DP) && routeChangeReasonInteger == AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue {
                                dispatch_async(dispatch_get_main_queue(), {
                                    Logger.writeToLogFile("AVSessionManager.audioInterrupted sending Swift-Music-Player.pauseAudio notification")
                                    Logger.writeToLogFile("AVSessionManager.routeChanged sending Swift-Music-Player.updatePlayPauseButton notification")
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.pauseAudio", object:self)
                                    NSNotificationCenter.defaultCenter().postNotificationName("Swift-Music-Player.updatePlayPauseButton", object:self, userInfo:["isPlaying": NSNumber(bool: false)])
                                })
                            }
                        }
                    }
                }
            }
        }
        
        //Logger.writeToLogFile("Leaving \(#function)")
    }
}
