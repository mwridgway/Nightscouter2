//
//  SocketClient.swift
//  NightscouterSocketTest
//
//  Created by Peter Ina on 1/4/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import SwiftyJSON
import ReactiveCocoa
import CryptoSwift
import Alamofire

public class NightscoutSocketIOClient {
    
    // From ericmarkmartin... RAC integration
    public let signal: Signal<[AnyObject], NSError>
    
    private var url: NSURL!
    
    // TODO: Refactor out...
    private var site: Site
    
    private var apiSecret: String
    public let socket: SocketIOClient
    private var authorizationJSON: AnyObject {
        // Turn the the authorization dictionary into a JSON object.
        
        var json = JSON([SocketHeader.Client : JSON(SocketValue.ClientMobile), SocketHeader.Secret: JSON(apiSecret.sha1())])
        
        return json.object
    }
    
    
    // API Secret is required for any site that is greater than 0.9.0 or better.
    public init(site: Site) {
        
        self.site = site
        self.url = site.url.URLByDeletingTrailingSlash
        self.apiSecret = site.apiSecret ?? ""
        
        // Create a socket.io client with a url string.
        self.socket = SocketIOClient(socketURL: url.absoluteString, options: [.Log(false), .ForcePolling(false)])
        
        // From ericmarkmartin... RAC integration
        self.signal = socket.rac_socketSignal()
        
        self.site.milliseconds = NSDate().timeIntervalSince1970 * 1000
        
        
        // Listen to connect.
        socket.on(WebEvents.connect.rawValue) { data, ack in
            print("socket connected")
            self.socket.emit(WebEvents.authorize.rawValue, self.authorizationJSON)
        }
        
        // Start up the whole thing.
        socket.connect()
    }
    
    deinit {
        socket.close()
    }
}

// TODO: Refactor out of this class...
// Extending the VC, but all of this should be in a data store of some kind.

extension NightscoutSocketIOClient {
    
    private func addConfigurationDataToSite(site: Site) {
        var headers: [String: String] = ["Content-Type": "application/json"]
        headers["api-secret"] = self.apiSecret.sha1()
        let configurationURL = self.url.URLByAppendingPathComponent("api/v1/status").URLByAppendingPathExtension("json")
        
        self.makeHTTPGetRequest(configurationURL, parameters: nil, headers:  headers, completetion: { (result) -> Void in
            if let jsonDict = result.dictionaryObject {
                self.site.parseJSONforConfiugration(JSON(jsonDict))
            }
        })
    }
    
    private func addValuesFromJson(site: Site, data: [AnyObject]) {
        let json = JSON(data[0])
        
        self.site.parseJSONforSocketData(json)
    }
    
    public func mapConfigurationValues() -> SignalProducer<Site, NSError> {
        self.addConfigurationDataToSite(self.site)
        
        return SignalProducer(value: site)
        
        
    }
    
    
    public func mapToJsonValues() -> Signal<Site, NSError> {
        return self.signal.map { data in
            
            self.addValuesFromJson(self.site, data: data)
            
            return self.site
        }
    }
    
    public func mapToSite() -> Signal<Site, NSError> {
        return self.signal.map { data in
            self.addConfigurationDataToSite(self.site)
            self.addValuesFromJson(self.site, data: data)
            
            return self.site
        }
    }
    
    private func makeHTTPGetRequest (url: NSURL, parameters: [String: String]?, headers: [String: String]?, completetion:(result: JSON) -> Void) {
        Alamofire.Manager.sharedInstance.request(.GET, url,  parameters: parameters, headers: headers)
            /// Becuase Nightscout uses scientific notation in the json for some numbers. for example, intercept":-1.7976931348623157e+308, I can't use the json response handler. Instead I need to take the raw data, convert it to a string, remove the "+" and then create json.
            .responseData { (response: Response<NSData, NSError>) -> Void in
                switch response.result {
                case .Success(let data):
                    guard var stringVersion = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                        break
                    }
                    stringVersion = stringVersion.stringByReplacingOccurrencesOfString("+", withString: "")
                    
                    if let newData = stringVersion.dataUsingEncoding(NSUTF8StringEncoding) {
                        let json = JSON(data: newData)
                        completetion(result: json)
                    }
                case .Failure(let error):
                    print(error)
                    break
                }
        }
    }
    
    
}

public enum ClientNotifications: String {
    case comNightscouterDataUpdate
}

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