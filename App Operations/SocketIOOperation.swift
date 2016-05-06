//
//  File.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import Operations
import SocketIOClientSwift
import SwiftyJSON

public enum SocketIOOperationError: ErrorType {
    case SocketDidDisconnect(NSError)
    case SocketError(NSError)
}

public class SocketIOOperation: Operation {
    
    // Data events that I'm aware of.
    enum WebEvents: String {
        case dataUpdate
        case connect
        case disconnect
        case authorize
    }
    // Header strings
    struct SocketHeader {
        static let Client = "client"
        static let Secret = "secret"
    }
    
    // Header values (strings)
    struct SocketValue {
        static let ClientMobile = "mobile"
    }
    
    public typealias CompletionBlockType = JSON -> Void
    
    private let socket: SocketIOClient
    private let completion: CompletionBlockType
    
    /// - returns: the CLLocation if available
    public private(set) var socketData: JSON = [:]
    
    public var result: JSON? {
        return socketData
    }
    
    public init(socketClient socket: SocketIOClient, apiSecret: String, completion: CompletionBlockType) {
        self.socket = socket
        self.completion = completion

        super.init()
        
        let encodedSecret = generateAuthorizationJSON(withApiSecretString: apiSecret)
        
        socket.onAny({ (anyEvent) in
            print("\(#function) - onAny: \(anyEvent.event) with items.count: \(anyEvent.items?.count)")
            
            let event = anyEvent.event
            let items = anyEvent.items
            
            switch event {
                
            case WebEvents.connect.rawValue:
                socket.emit(WebEvents.authorize.rawValue, encodedSecret)
                
            case WebEvents.dataUpdate.rawValue:
                if !self.finished, let data = items?.firstObject as? [String: AnyObject] {
                    let resultToSend = (JSON(data), event)
                    dispatch_async(Queue.Main.queue) { [weak self] in
                        if let weakSelf = self {
                            if !weakSelf.finished {
                                // weakSelf.stopLocationUpdates()
                                weakSelf.socketData = resultToSend.0
                                weakSelf.completion(resultToSend.0)
                                // Should I not fiinsh?
                                weakSelf.finish()
                            }
                        }
                    }
                    
                } else {
                    dispatch_async(Queue.Main.queue) { [weak self] in
                        if let weakSelf = self {
                            weakSelf.finish()
                        }
                    }
                    
                }
                
            case WebEvents.disconnect.rawValue:
                dispatch_async(Queue.Main.queue) { [weak self] in
                    if let weakSelf = self {
                        weakSelf.finish()
                    }
                }
                
            default:
                print("Unhandled event (\(event)) was sent with items:\(items)")
            }
        })
        
        
        
        
        
        name = "Socket Connection"
        
        
    }
    
    override public func execute() {
        socket.connect()
    }
    
    public override func cancel() {
        socket.disconnect()
    }
    
    deinit {
        socket.disconnect()
    }
    
    private func generateAuthorizationJSON(withApiSecretString apiSecret: String) -> AnyObject {
        // Turn the the authorization dictionary into a JSON object.
        
        var json = JSON([SocketHeader.Client : JSON(SocketValue.ClientMobile), SocketHeader.Secret: JSON(apiSecret.sha1())])
        
        return json.object
    }
    
}