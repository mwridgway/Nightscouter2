//
//  SocketSignal.swift
//  NightscouterSocketTest
//
//  Created by Eric Martin on 1/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import ReactiveCocoa
import SwiftyJSON

public extension SocketIOClient {
    public func rac_socketSignal() -> Signal<[AnyObject], NSError> {
        let (tmpSignal, observer) = Signal<[AnyObject], NSError>.pipe()
        
        self.on(WebEvents.disconnect.rawValue) { data, ack in
            print("socketSignal complete")
            observer.sendCompleted()
        }
        
        self.on(WebEvents.dataUpdate.rawValue) { data, ack in
            print("socketSignal dataUpdate for \(self.socketURL)")
            observer.sendNext(data)
        }
        
        return tmpSignal
    }
}

/// New stuff
private func generateConfigurationRequestHeader(withURL url: NSURL, withApiSecretString apiSecret: String) -> NSMutableURLRequest {
    var headers: [String: String] = ["Content-Type": "application/json"]
    headers["api-secret"] = apiSecret.sha1()
    let configurationURL = url.URLByAppendingPathComponent("api/v1/status").URLByAppendingPathExtension("json")
    let request = NSMutableURLRequest(URL: configurationURL)
    
    for (headerField, headerValue) in headers {
        request.setValue(headerValue, forHTTPHeaderField: headerField)
    }
    return request
}



public func rac_nightscouterFetchSiteConfigurationData(withSite site: Site) -> SignalProducer<ServerConfiguration?, NSError>  {
    return rac_nightscouterFetchSiteConfigurationData(withURL: site.url, withApiSecretString: site.apiSecret ?? "")
}


public func rac_nightscouterFetchSiteConfigurationData(withURL url: NSURL, withApiSecretString apiSecret: String) -> SignalProducer<ServerConfiguration?, NSError> {
    let request = generateConfigurationRequestHeader(withURL: url, withApiSecretString: apiSecret)
    
    return NSURLSession.sharedSession().rac_dataWithRequest(request)
        .map { data, response in
            guard var stringVersion = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                return nil
            }
            stringVersion = stringVersion.stringByReplacingOccurrencesOfString("+", withString: "")
            
            guard let newData = stringVersion.dataUsingEncoding(NSUTF8StringEncoding), json = JSON(data: newData).dictionaryObject else {
                return nil
            }
            
            guard let configuration = ServerConfiguration.decode(json) else {
                return nil
            }
            
            return configuration
    }
}

private func generateAuthorizationJSON(withApiSecretString apiSecret: String) -> AnyObject {
    // Turn the the authorization dictionary into a JSON object.
    
    var json = JSON([SocketHeader.Client : JSON(SocketValue.ClientMobile), SocketHeader.Secret: JSON(apiSecret.sha1())])
    
    return json.object
}

private let defaultSocketError = NSError(domain: "com.nothingonline.nightscouter.ReactiveCocoa.rac_nightscouterConnectToSocketSignal", code: 1, userInfo: nil)

public func rac_nightscouterConnectToSocketSignal(withSite site: Site)  -> SignalProducer<(JSON
    , String), NSError> {
        return rac_nightscouterConnectToSocketSignal(withURL: site.url, withApiSecretString: site.apiSecret ?? "" )
}

public func rac_generateTimeline() -> SignalProducer<[ComplicationTimelineEntry], NoError> {
    return  SignalProducer { observer, disposable in
        observer.sendCompleted()
    }
}

public func rac_nightscouterConnectToSocketSignal(withURL url: NSURL, withApiSecretString apiSecret: String) -> SignalProducer<(JSON
    , String), NSError> {
        
        let newUrl = url.URLByDeletingTrailingSlash!
        let apiSecret = generateAuthorizationJSON(withApiSecretString: apiSecret)
        
        return SignalProducer { observer, disposable in
            
            let socket = SocketIOClient(socketURL: newUrl, options: [.Log(false), .ForceNew(false), .ForcePolling(false)])
            
            socket.onAny({ (anyEvent) in
                // print("onAny: \(anyEvent.event) with items.count: \(anyEvent.items?.count)")
                
                let event = anyEvent.event
                let items = anyEvent.items
                
                switch event {
                    
                case WebEvents.connect.rawValue:
                    socket.emit(WebEvents.authorize.rawValue, apiSecret)
                    
                case WebEvents.dataUpdate.rawValue:
                    
                    if let data = items?.firstObject as? [String: AnyObject] {
                        let resultToSend = (JSON(data), event)
                        observer.sendNext(resultToSend)
                    } else {
                        observer.sendFailed(defaultSocketError)
                    }
                    
                case WebEvents.disconnect.rawValue:
                    observer.sendCompleted()
                    
                default:
                    print(event)
                    print("Unhandled event (\(event)) was sent with items:\(items)")
                }
            })
            
            disposable.addDisposable({
                socket.disconnect()
            })
            
            // Start up the whole thing.
            socket.connect()
        }
}