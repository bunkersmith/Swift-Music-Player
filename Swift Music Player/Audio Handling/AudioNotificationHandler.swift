//
//  AudioNotificationHandler.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/22/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import AVFoundation

class AudioNotificationHandler: NSObject {
    
    // Singleton instance
    static let instance = AudioNotificationHandler()
    
    //fileprivate var shouldResumeAudio:Bool = false
    fileprivate lazy var songManager = SongManager.instance
    
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        enableDisableRouteChangedObserver(enableFlag: true)
        enableDisableAudioInterruptionObserver(enableFlag: true)
        notificationCenter.addObserver(self, selector:#selector(mediaServicesReset(_:)), name:NSNotification.Name.AVAudioSessionMediaServicesWereReset, object:nil)
    }
    
    func removeNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        enableDisableRouteChangedObserver(enableFlag: false)
        enableDisableAudioInterruptionObserver(enableFlag: false)
        notificationCenter.removeObserver(self, name:NSNotification.Name.AVAudioSessionMediaServicesWereReset, object:nil)
    }

    func mediaServicesReset(_ notification: Notification)
    {
        Logger.logDetails(msg:"Called with notification = \(notification)")
    }
    
    func enableDisableRouteChangedObserver(enableFlag: Bool) {
        let notificationCenter = NotificationCenter.default
        if enableFlag {
            notificationCenter.addObserver(self, selector: #selector(routeChanged(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        }
    }
    
    func enableDisableAudioInterruptionObserver(enableFlag: Bool) {
        let notificationCenter = NotificationCenter.default
        if enableFlag {
            notificationCenter.addObserver(self, selector: #selector(routeChanged(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        } else {
            notificationCenter.removeObserver(self, name:NSNotification.Name.AVAudioSessionInterruption, object:nil)
        }
    }
    
    func routeChangeReasonToString(_ routeChangeReason: AVAudioSessionRouteChangeReason) -> String {
        
        switch routeChangeReason {
            case .unknown:
                return "Unknown"
            case .newDeviceAvailable:
                return "NewDeviceAvailable"
            case .oldDeviceUnavailable:
                return "OldDeviceUnavailable"
            case .categoryChange:
                return "CategoryChange"
            case .override:
                return "Override"
            case .wakeFromSleep:
                return "WakeFromSleep"
            case .noSuitableRouteForCategory:
                return "NoSuitableRouteForCategory"
            case .routeConfigurationChange:
                return "RouteConfigurationChange"
        }
    }
    
    func audioInterruptionTypeToString(_ interruptionType: AVAudioSessionInterruptionType) -> String {
        switch interruptionType {
        case .began:
            return "Began"
        case .ended:
            return "Ended"
        }
    }
    
    func audioInterrupted(_ notification: Notification)
    {
        enableDisableAudioInterruptionObserver(enableFlag: false)

        Logger.logDetails(msg:"Entered")
        
        guard let userInfo:[AnyHashable: Any] = (notification as NSNotification).userInfo else {
            Logger.logDetails(msg:"Notification has no userInfo")
            enableDisableAudioInterruptionObserver(enableFlag: true)
            return
        }
        
        guard let interruptionTypeNumber:NSNumber = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else {
            Logger.logDetails(msg:"Notification has no interruption type number")
            enableDisableAudioInterruptionObserver(enableFlag: true)
            return
        }
        
        guard let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeNumber.uintValue) else {
            Logger.logDetails(msg:"Notification has no interruption type")
            enableDisableAudioInterruptionObserver(enableFlag: true)
            return
        }
        
        Logger.writeToLogFile("interruptionType = \(audioInterruptionTypeToString(interruptionType))")
        
        if interruptionType == .began {
            //shouldResumeAudio = songManager.isAudioPlaying()
            
            DispatchQueue.main.async(execute: { 
                Logger.writeToLogFile("AVSessionManager.audioInterrupted (Began case) sending Swift-Music-Player.audioPaused notification")
                Logger.writeToLogFile("AVSessionManager.audioInterrupted (Began case) sending Swift-Music-Player.updatePlayPauseButton notification")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.audioPaused"), object:self)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.updatePlayPauseButton"), object:self, userInfo:["isPlaying": NSNumber(value: false as Bool)])
                
                Logger.logDetails(msg:"Leaving audioInterrupted")
                self.enableDisableAudioInterruptionObserver(enableFlag: true)
            })
        }
        else {
            guard interruptionType == .ended else {
                Logger.writeToLogFile("Interruption type is not began or ended")
                enableDisableAudioInterruptionObserver(enableFlag: true)
                return
            }
            
/*
            Logger.writeToLogFile("shouldResumeAudio = \(shouldResumeAudio)")
            
            guard shouldResumeAudio else {
                return
            }
        
            shouldResumeAudio = false
*/
            
            guard let interruptionOptionsNumber:NSNumber = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber else {
                Logger.logDetails(msg:"Notification has no interruption options number")
                enableDisableAudioInterruptionObserver(enableFlag: true)
                return
            }
            
            let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: interruptionOptionsNumber.uintValue)
            
            guard interruptionOptions == .shouldResume else {
                Logger.logDetails(msg:"Notification has no interruption options")
                enableDisableAudioInterruptionObserver(enableFlag: true)
                return
            }
            
            Logger.writeToLogFile("interruptionOptions == .ShouldResume")
            
            let restartTime:DispatchTime = DispatchTime.now() + Double(Int64(2) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.global(qos: .default).asyncAfter(deadline: restartTime, execute: { () -> Void in
                // Resume the audio and update the play button
                Logger.writeToLogFile("AVSessionManager.audioInterrupted sending Swift-Music-Player.playAudio notification")
                Logger.writeToLogFile("AVSessionManager.audioInterrupted (Ended case) sending Swift-Music-Player.updatePlayPauseButton notification")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.playAudio"), object:self)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.updatePlayPauseButton"), object:self, userInfo:["isPlaying": NSNumber(value: true as Bool)])
                
                Logger.logDetails(msg:"Leaving audioInterrupted")
                self.enableDisableAudioInterruptionObserver(enableFlag: true)
            })
        }
    }
    
    func routeChanged(_ notification: Notification)
    {
        enableDisableRouteChangedObserver(enableFlag: false)
        
        //Logger.logDetails(msg:"Entered")
        
        guard let userInfo = (notification as NSNotification).userInfo else {
            Logger.logDetails(msg:"userInfo is nil")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        guard let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else {
            Logger.logDetails(msg:"previousRoute is nil")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        guard let routeChangeReasonNumber = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber else {
            Logger.logDetails(msg:"routeChangeReasonNumber is nil")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        guard let routeChangeReason = AVAudioSessionRouteChangeReason(rawValue: routeChangeReasonNumber.uintValue) else {
            Logger.logDetails(msg:"routeChangeReason is nil")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        guard routeChangeReason == .oldDeviceUnavailable else {
            Logger.logDetails(msg:"routeChangeReason is not oldDeviceUnavailable")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        Logger.writeToLogFile("previousRoute.outputs = \(previousRoute.outputs)")
        
        Logger.writeToLogFile("routeChangeReason = \(routeChangeReasonToString(routeChangeReason))")
        
        guard previousRoute.outputs.count > 0 else {
            Logger.logDetails(msg:"No previous route outputs")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        guard let previousOutputPort:AVAudioSessionPortDescription = previousRoute.outputs.first else {
            Logger.logDetails(msg:"previousOutputPort is nil")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        Logger.writeToLogFile("previousOutputPort.portType = \(previousOutputPort.portType)")
        
        guard (previousOutputPort.portType == AVAudioSessionPortHeadphones || previousOutputPort.portType == AVAudioSessionPortBluetoothA2DP) && routeChangeReason == .oldDeviceUnavailable else {
            Logger.logDetails(msg:"previousOutputPort type is not Bluetooth or headphones")
            enableDisableRouteChangedObserver(enableFlag: true)
            return
        }
        
        DispatchQueue.main.async(execute: {
            Logger.writeToLogFile("AVSessionManager.routeChanged sending Swift-Music-Player.pauseAudio notification")
            Logger.writeToLogFile("AVSessionManager.routeChanged sending Swift-Music-Player.updatePlayPauseButton notification")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.pauseAudio"), object:self)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Swift-Music-Player.updatePlayPauseButton"), object:self, userInfo:["isPlaying": NSNumber(value: false as Bool)])
            
            Logger.logDetails(msg:"Leaving routeChanged")
            self.enableDisableRouteChangedObserver(enableFlag: true)
        })
    }
}
