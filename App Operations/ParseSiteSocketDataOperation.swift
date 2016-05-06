//
//  ParseSiteDataOperation.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import NightscouterKit
import Operations
import SwiftyJSON

public struct ParsedSocketIODataObject: Dateable {
    public var milliseconds: Mills
    public var sgvs: [SensorGlucoseValue] = []
    public var cals: [Calibration] = []
    public var mbgs: [MeteredGlucoseValue] = []
    public var deviceStatuses: [DeviceStatus] = []
}

/// An `Operation` to parse earthquakes out of a downloaded feed from the USGS.
class ParseSiteSocketDataOperation: Operation {
    let cacheFile: NSURL
    var site: Site
    
    init(cacheFile: NSURL, forSite site: Site) {
        print(#function)
        
        self.cacheFile = cacheFile
        self.site = site
        super.init()
        
        name = "Parse Site Socket.io Data"
    }
    
    override func execute() {
        guard let stream = NSInputStream(URL: cacheFile) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithStream(stream, options: []) as? [String: AnyObject]
            
            if let features = json {
                parse(features)
            }
            else {
                finish()
            }
        }
        catch let jsonError as NSError {
            //finishWithError(jsonError)
            finish([jsonError])
        }
    }
    
    private func parse(features: [String: AnyObject]) {
        print(#function)
        let json = JSON(features)
        
        var newData: ParsedSocketIODataObject = ParsedSocketIODataObject(milliseconds: 0, sgvs: [], cals: [], mbgs: [], deviceStatuses: [])
        
        if let lastUpdated = json[Site.JSONKey.lastUpdated].double {
            newData.milliseconds = lastUpdated
        }
        
        newData.deviceStatuses.insertOrUpdate(DeviceStatus.decode(features)!)
        
        let deviceStatus = json[DeviceStatus.JSONKey.devicestatus]
        print("deviceStatus count: \(deviceStatus.count)")
        
        for (_, subJson) in deviceStatus {
            newData.deviceStatuses.insertOrUpdate(DeviceStatus.decode(subJson.dictionaryObject ?? [:])!)
        }
        
        let sgvs = json[GlobalJSONKey.sgvs]
        print("sgv count: \(sgvs.count)")
        
        for (_, subJson) in sgvs {
            newData.sgvs.insertOrUpdate(SensorGlucoseValue.decode(subJson.dictionaryObject ?? [:])!)
        }
        
        let mbgs = json[GlobalJSONKey.mbgs]
        print("mbgs count: \(mbgs.count)")
        
        for (_, subJson) in mbgs {
            newData.mbgs.insertOrUpdate(MeteredGlucoseValue.decode(subJson.dictionaryObject ?? [:])!)
        }
        
        let cals = json[GlobalJSONKey.cals]
        print("cals count: \(cals.count)")
        
        for (_, subJson) in cals {
            newData.cals.insertOrUpdate(Calibration.decode(subJson.dictionaryObject ?? [:])!)
        }
        
        // makes sure things are sorted correctly by date. When delta's come in they might screw up the order.
        newData.sgvs.sortByDate()
        newData.cals.sortByDate()
        newData.mbgs.sortByDate()
        newData.deviceStatuses.sortByDate()
        
    }
    
}
