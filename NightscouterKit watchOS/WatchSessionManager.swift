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
    
    private var sites: [Site] = []
    
    public func startSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activateSession()
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
//            print(": \(userInfo)")
        SitesDataSource.sharedInstance.loadDefaults(fromDictionary: userInfo)

        
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimelineForComplication(complication)
                          //      complicationServer.extendTimelineForComplication(complication)
            }
        }
        //processApplicationContext(userInfo)
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        // print("didReceiveApplicationContext: \(applicationContext)")
        processApplicationContext(applicationContext)
    }
    
    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let success =  processApplicationContext(message)
        replyHandler(["response" : "The message was procssed correctly: \(success)", "success": success])
    }
    
}

extension WatchSessionManager {
    public func requestLatestAppContext() -> Bool {
        print("requestLatestAppContext")
        
        var returnBool = false
        
        session.sendMessage(["test" : "TEST"], replyHandler: {(context:[String : AnyObject]) -> Void in
            // handle reply from iPhone app here
            
            // print("recievedMessageReply: \(context)")
            
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
                print("error: \(error)")
                
                returnBool = false
                
        })
        return returnBool
    }
    
    func processApplicationContext(context: [String : AnyObject]) -> Bool {
        print("processApplicationContext \(context)")
        
        return false
    }
    
}
