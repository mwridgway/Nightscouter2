//
//  SocketQueue.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/6/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//
/*
 Socket IO as an GroupOperation
 */

import Foundation
import Operations
import SocketIOClientSwift
import NightscouterKit
import SwiftyJSON

public class SocketSetupOperation {
    
    private var queue = NSOperationQueue()
    
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
    
    private var sockets: [SocketIOClient] = []
    
    public static let sharedInstance = SocketSetupOperation()
    
    public func createSocket(forSite site: Site) {
        
        let siteSocket = SocketIOClient(socketURL: site.url)
        
//        if !sockets.contains(siteSocket) {
        
            let encodedSecret = generateAuthorizationJSON(withApiSecretString: site.apiSecret)
            siteSocket.onAny({ (anyEvent) in
                // print("\(#function) - onAny: \(anyEvent.event) with items.count: \(anyEvent.items?.count)")
                
                let event = anyEvent.event
                let items = anyEvent.items
                
                switch event {
                    
                case WebEvents.connect.rawValue:
                    siteSocket.emit(WebEvents.authorize.rawValue, encodedSecret)
                    
                case WebEvents.dataUpdate.rawValue:
                    print("dataUpdate")

                    if let data = items?.firstObject as? [String: AnyObject] {
                        //let resultToSend = (JSON(data), event)
                        // create a new operation that parses and updates the model?
                        let socketParser = ParseSiteSocketDataOperation(withSocketData: data, forSite: site)
                        
                        let complicationGenerator = ComplicationTimelineGenerationOperation(forSite: site)
//                        complicationGenerator.injectResultFromDependency(socketParser)

                        complicationGenerator.addDependency(socketParser)

                        
                        // add new operation to queue?
                        self.queue.addOperations([socketParser, complicationGenerator])
                    }
                case WebEvents.disconnect.rawValue:
                    print("disconnect")
                default:
                    print("Unhandled event (\(event)) was sent with items:\(items)")
                }
            })
            
            siteSocket.connect()
            sockets.insertOrUpdate(siteSocket)
            
//        }
        
    }
    
    
    private func generateAuthorizationJSON(withApiSecretString apiSecret: String) -> AnyObject {
        // Turn the the authorization dictionary into a JSON object.
        
        var json = JSON([SocketHeader.Client : JSON(SocketValue.ClientMobile), SocketHeader.Secret: JSON(apiSecret.sha1())])
        
        return json.object
    }
    
}

public func ==(lhs: SocketIOClient, rhs: SocketIOClient) -> Bool {
    return lhs.sid == rhs.sid
}
