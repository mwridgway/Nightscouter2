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

public class NightscoutSocketIOClient {
    
    // From ericmarkmartin... RAC integration
    public let signal: Signal<[AnyObject], NSError>
    
    private var url: NSURL!
    
    // TODO: Refactor out...
    private var site: Site?
    
    private var apiSecret: String?
    private let socket: SocketIOClient
    private var authorizationJSON: AnyObject {
        // Turn the the authorization dictionary into a JSON object.
        
        var json = JSON([SocketHeader.Client : JSON(SocketValue.ClientMobile), SocketHeader.Secret: JSON(apiSecret ?? "")])
        
        return json.object
    }
    
    
    // API Secret is required for any site that is greater than 0.9.0 or better.
    public init(url: NSURL, apiSecret: String? = nil) {
        
        self.url = url
        self.apiSecret = apiSecret
        
        // Create a socket.io client with a url string.
        self.socket = SocketIOClient(socketURL: url.absoluteString, options: [.Log(true), .ForcePolling(false)])
        
        // From ericmarkmartin... RAC integration
        self.signal = socket.rac_socketSignal()
        
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
    
    func mapToJsonValues() -> Signal<Site, NSError> {
        return self.signal.map { data in
            
            let json = JSON(data[0])
            
            if self.site == nil {
                self.site = Site()
            }
            
            if var site = self.site {
                if let lastUpdated = json[JSONProperty.lastUpdated].double {
                    // print(lastUpdated)
                    site.milliseconds = lastUpdated
                }
                
                if let uploaderBattery = json[JSONProperty.devicestatus][JSONProperty.uploaderBattery].int {
                    site.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: 0))
                }
                
                let deviceStatus = json[JSONProperty.devicestatus]
                
                for (_, subJson) in deviceStatus {
                    print(subJson.description)
                    if let mills = subJson[JSONProperty.mills].double {
                        if let uploaderBattery = subJson[JSONProperty.uploader, JSONProperty.battery].int {
                            site.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills))
                        }
                    }
                }
                
                
                let sgvs = json[JSONProperty.sgvs]
                for (_, subJson) in sgvs {
                    if let deviceString = subJson[JSONProperty.device].string, rssi = subJson[JSONProperty.rssi].int, unfiltered = subJson[JSONProperty.unfiltered].double, directionString = subJson[JSONProperty.direction].string, filtered = subJson[JSONProperty.filtered].double, noiseInt = subJson[JSONProperty.noise].int, mills = subJson[JSONProperty.mills].double, mgdl = subJson[JSONProperty.mgdl].double {
                        
                        let device = Device(rawValue: deviceString) ?? Device.Unknown
                        let direction = Direction(rawValue: directionString) ?? Direction.None
                        let noise = Noise(rawValue: noiseInt) ?? Noise()
                        
                        let sensorValue = SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mills)
                        
                        //SensorGlucoseValue(device: device, rssi: rssi, unfiltered: unfiltered, direction: direction, filtered: filtered, noise: Noise(rawValue: noise) ?? Noise() , milliseconds: mills, mgdl: mgdl)
                        
                        site.sgvs.append(sensorValue)
                        // print(sensorValue)
                    }
                }
                
                let mbgs = json[JSONProperty.mbgs]
                for (_, subJson) in mbgs {
                    if let deviceString = subJson[JSONProperty.device].string, mills = subJson[JSONProperty.mills].double, mgdl = subJson[JSONProperty.mgdl].double {
                        let device = Device(rawValue: deviceString) ?? Device.Unknown
                        
                        let meter = MeteredGlucoseValue(milliseconds: mills, device: device, mgdl: mgdl)
                        site.mbgs.append(meter)
                        // print(meter)
                    }
                }
                
                let cals = json[JSONProperty.cals]
                for (_, subJson) in cals {
                    if let slope = subJson[JSONProperty.slope].double, intercept = subJson[JSONProperty.intercept].double, scale = subJson[JSONProperty.scale].double, mills = subJson[JSONProperty.mills].double {
                        
                        let calibration = Calibration(slope: slope, intercept: intercept, scale: scale, milliseconds: mills)
                        
                        site.cals.append(calibration)
                        // print(calibration)
                    }
                }
                // print(site)
                
                // makes sure things are sorted correctly by date. When delta's come in they might screw up the order.
                site.sgvs = site.sgvs.sort{(item1:SensorGlucoseValue, item2:SensorGlucoseValue) -> Bool in
                    item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
                }
                site.cals = site.cals.sort{(item1:Calibration, item2:Calibration) -> Bool in
                    item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
                }
                site.mbgs = site.mbgs.sort{(item1:MeteredGlucoseValue, item2:MeteredGlucoseValue) -> Bool in
                    item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
                }
                
                self.site = site
                return site
                
            }
            return self.site!
        }
    }
}

// All the JSON keys I saw when parsing the socket.io output for dataUpdate
struct JSONProperty {
    static let lastUpdated = "lastUpdated"
    static let devicestatus = "devicestatus"
    static let uploader = "uploader"
    static let battery = "battery"
    static let sgvs = "sgvs"
    static let mbgs = "mbgs"
    static let cals = "cals"
    static let slope = "slope"
    static let intercept = "intercept"
    static let scale = "scale"
    static let mills = "mills"
    static let mgdl = "mgdl"
    static let uploaderBattery = "uploaderBattery"
    static let device = "device"
    static let rssi = "rssi"
    static let filtered = "filtered"
    static let unfiltered = "unfiltered"
    static let direction = "direction"
    static let noise = "noise"
    static let profiles = "profiles"
    static let treatments = "treatments"
    static let deltaCount = "delta"
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