//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//

import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func session(session: WCSession, didReceiveContext context: [String: AnyObject])
}

@available(iOSApplicationExtension 9.0, *)
public class WatchSessionManager: NSObject, WCSessionDelegate, SessionManagerType {
    
    public static let sharedManager = WatchSessionManager()
    
    /// The store that the session manager should interact with.
    public var store: SiteStoreType?

    private override init() {
        
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    
    public func startSession() {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
        #endif
        
        session?.delegate = self
        session?.activateSession()
        
        #if DEBUG
            print("WCSession.isSupported: \(WCSession.isSupported()), Paired Watch: \(session?.paired), Watch App Installed: \(session?.watchAppInstalled)")
        #endif
    }
    
}

public extension WatchSessionManager {
    public func sessionReachabilityDidChange(session: WCSession) {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
        #endif
    }
    
    public func sessionWatchStateDidChange(session: WCSession) {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
        #endif
    }
}

// MARK: Application Context
// use when your app needs only the latest information
// if the data was not sent, it will be replaced
@available(iOSApplicationExtension 9.0, *)
public extension WatchSessionManager {
    
    // Sender
    public func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
        #endif
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        // handle receiving application context
        dispatch_async(dispatch_get_main_queue()) {
            self.processApplicationContext(applicationContext)
        }      
    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
@available(iOSApplicationExtension 9.0, *)
extension WatchSessionManager {
    
    public func transferCurrentComplicationUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            // print("transferUserInfo: \(userInfo)")
            print("validSession?.complicationEnabled == \(validReachableSession?.complicationEnabled)")
        #endif
        // return validSession?.transferCurrentComplicationUserInfo(userInfo)
        cleanUpTransfers()
        
        return validSession?.complicationEnabled == true ? validSession?.transferCurrentComplicationUserInfo(userInfo) : transferUserInfo(userInfo)
    }
    
    // Sender
    public func transferUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            print("transferUserInfo: \(userInfo)")
        #endif
        
        return validSession?.complicationEnabled == true ? validSession?.transferCurrentComplicationUserInfo(userInfo) : transferUserInfo(userInfo)
    }
    
    func cleanUpTransfers(){
        validReachableSession?.outstandingFileTransfers.forEach({ $0.cancel() })
    }
    
    public func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            print("session \(session), didFinishUserInfoTransfer: \(userInfoTransfer), error: \(error)")
        #endif
        
        // implement this on the sender if you need to confirm that
        // the user info did in fact transfer.
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            print("session \(session), didReceiveUserInfo: \(userInfo)")
        #endif
        // handle receiving user info
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
    
}

// MARK: Transfer File
@available(iOSApplicationExtension 9.0, *)
extension WatchSessionManager {
    
    // Sender
    public func transferFile(file: NSURL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file, metadata: metadata)
    }
    
    public func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        #if DEBUG
            print("session \(session), didFinishFileTransfer: \(fileTransfer), error: \(error)")
        #endif
        // handle filed transfer completion
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        #if DEBUG
            print("session \(session), didReceiveFile: \(file)")
        #endif
        // handle receiving file
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
}


// MARK: Interactive Messaging
@available(iOSApplicationExtension 9.0, *)
extension WatchSessionManager {
    
    // Live messaging! App has to be reachable
    public var validReachableSession: WCSession? {
        if let session = validSession where session.reachable {
            return session
        }
        return nil
    }
    
    // Sender
    public func sendMessage(message: [String : AnyObject],
        replyHandler: (([String : AnyObject]) -> Void)? = nil,
        errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    public func sendMessageData(data: NSData,
        replyHandler: ((NSData) -> Void)? = nil,
        errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    // Receiver
    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        // handle receiving message
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            print("session: \(session), didReceiveMessage: \(message)")
        #endif
        
        dispatch_async(dispatch_get_main_queue()) {
            // Process context in the datasource.
            self.processApplicationContext(message)
        }
    }
    
    public func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        
        #if DEBUG
            print(">>> Entering \(#function) <<<")
            print("session: \(session), messageData: \(messageData)")
        #endif
        
        // handle receiving message data
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
}

extension WatchSessionManager {
    
    func processApplicationContext(context: [String : AnyObject]) -> Bool {
        print("processApplicationContext \(context)")
        
        print("Did receive payload: \(context)")
        
        guard let store = store else {
            print("No Store")
            return false
        }
        
        store.handleApplicationContextPayload(context)
        
        return true
    }
    
}
