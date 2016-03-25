//
//  SocketClient.swift
//  NightscouterSocketTest
//
//  Created by Peter Ina on 1/4/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import SwiftyJSON
import ReactiveCocoa
import CryptoSwift
import Alamofire

public class NightscoutSocketIOClient {
    
    private var url: NSURL!
    
    // TODO: Refactor out...
    public var site: Site
    
    // From ericmarkmartin... RAC integration
    public let signal: Signal<[AnyObject], NSError>
    
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
        
        self.socket = SocketIOClient(socketURL: url, options: [.Log(false), .ForceNew(false), .ForcePolling(false)])
        
        // From ericmarkmartin... RAC integration
        self.signal = socket.rac_socketSignal()
        
        self.site.milliseconds = NSDate().timeIntervalSince1970 * 1000
        
        // Listen to connect.
        socket.on(WebEvents.connect.rawValue) { data, ack in
            print("socketSignal connected for \(self.socket.socketURL)")
            self.socket.emit(WebEvents.authorize.rawValue, self.authorizationJSON)
        }
        
        // Start up the whole thing.
        socket.connect()
    }
    
}

// TODO: Refactor out of this class...
// Extending the VC, but all of this should be in a data store of some kind.

extension NightscoutSocketIOClient {
    
    public func fetchConfigurationData() -> SignalProducer<Site?, NSError> {
        var headers: [String: String] = ["Content-Type": "application/json"]
        headers["api-secret"] = self.apiSecret.sha1()
        let configurationURL = self.url.URLByAppendingPathComponent("api/v1/status").URLByAppendingPathExtension("json")
        let request = NSMutableURLRequest(URL: configurationURL)
        
        for (headerField, headerValue) in headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                guard var stringVersion = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    return nil
                }
                stringVersion = stringVersion.stringByReplacingOccurrencesOfString("+", withString: "")
                
                guard let newData = stringVersion.dataUsingEncoding(NSUTF8StringEncoding), json = JSON(data: newData).dictionaryObject else {
                    return nil
                }
                self.site.configuration = ServerConfiguration.decode(json)
                return self.site
        }
    }
        
    public func fetchSocketData() -> Signal<Site, NSError> {
        return self.signal.map { data in
            let json = JSON(data[0])
            
            self.site.parseJSONforSocketData(json)
            self.site.generateTimeline()

            return self.site
        }
    }
}

public enum ClientNotifications: String {
    case NightscouterDataUpdate
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

struct SiteMetadata {
    let url: NSURL!
    let apiSecret: String
}

struct SiteUpdate {
    let site: Site
    let changeset: SiteChangeset
}

func changedSiteSignal(metadata: [SiteMetadata]) -> Signal<Site, NSError> {
    let (signal, observer) = Signal<Signal<Site, NSError>, NSError>.pipe()
    
    for datum in metadata {
        observer.sendNext(
            NightscoutSocketIOClient(
                site: Site(url: datum.url, apiSecret: datum.apiSecret)
            ).fetchSocketData()
        )
    }
    
    return signal.flatten(.Merge)
}

func changedSiteSignalWithChangesets(metadata: [SiteMetadata]) -> Signal<SiteUpdate, NSError> {
    let (signal, observer) = Signal<Signal<SiteUpdate, NSError>, NSError>.pipe()
    var sitesDict = [String: Site]()
    
    for datum in metadata {
        let site = Site(url: datum.url, apiSecret: datum.apiSecret)
        
        sitesDict[datum.url.absoluteString] = site
        
        observer.sendNext(
            NightscoutSocketIOClient(site: site).fetchSocketData().map { updatedSite in
                let changeset: SiteChangeset
                
                if let oldSite = sitesDict[updatedSite.url.absoluteString] {
                    changeset = SiteChangeset(site: oldSite, otherSite: updatedSite)
                } else {
                    changeset = SiteChangeset()
                }
                
                return SiteUpdate(site: updatedSite, changeset: changeset)
            }
        )
    }
    
    return signal.flatten(.Merge)
}