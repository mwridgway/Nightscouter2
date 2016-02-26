//
//  WatchSessionManager.swift
//  WCApplicationContextDemo
//
//  Created by Natasha Murashev on 9/22/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//

import WatchConnectivity
import ClockKit

@available(watchOS 2.0, *)
public protocol DataSourceChangedDelegate {
    //    func dataSourceDidUpdateAppContext(models: [WatchModel])
    //    func dataSourceCouldNotConnectToPhone(error: NSError)
    
    //    func dataSourceDidUpdateAppContext(models: [WatchModel])
    //    func dataSourceDidUpdateSiteModel(model: WatchModel, atIndex index: Int)
    //    func dataSourceDidAddSiteModel(model: WatchModel, atIndex index: Int)
    //    func dataSourceDidDeleteSiteModel(model: WatchModel, atIndex index: Int)
}

@available(watchOS 2.0, *)
public class WatchSessionManager: NSObject, WCSessionDelegate {
    
    public static let sharedManager = WatchSessionManager()
    
    private override init() {
        super.init()
    }
    
    private var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
    private let session: WCSession = WCSession.defaultSession()
    
    public func startSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activateSession()
            
            #if DEBUG
                print("WCSession.isSupported: \(WCSession.isSupported()), Paired Phone Reachable: \(session.reachable)")
            #endif
        }
    }
    
    public func addDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        dataSourceChangedDelegates.append(delegate)
    }
    
    public func removeDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        for (index, indexDelegate) in dataSourceChangedDelegates.enumerate() {
            if let indexDelegate = indexDelegate as? T where indexDelegate == delegate {
                dataSourceChangedDelegates.removeAtIndex(index)
                break
            }
        }
    }
}

// MARK: Application Context
// use when your app needs only the latest information
// if the data was not sent, it will be replaced
extension WatchSessionManager {
    public func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        // print("didReceiveFile: \(file)")
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
    
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("didReceiveUserInfo")
        // print(": \(userInfo)")
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.processApplicationContext(userInfo)

            let complicationServer = CLKComplicationServer.sharedInstance()
            if let activeComplications = complicationServer.activeComplications {
                for complication in activeComplications {
                    complicationServer.reloadTimelineForComplication(complication)
                }
            }
        }
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        // print("didReceiveApplicationContext: \(applicationContext)")
        dispatch_async(dispatch_get_main_queue()) {
            self.processApplicationContext(applicationContext)
        }
    }
    
    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let success =  processApplicationContext(message)
        replyHandler(["response" : "The message was procssed correctly: \(success)", "success": success])
    }
    
}

extension WatchSessionManager {
    
    func processApplicationContext(context: [String : AnyObject]) -> Bool {
        print("processApplicationContext \(context)")
        SitesDataSource.sharedInstance.loadDefaults(fromDictionary: context)

        return false
    }
    
}
