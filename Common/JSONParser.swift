//
//  JSONParser.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/20/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import SwiftyJSON

// All the JSON keys I saw when parsing the socket.io output for dataUpdate
struct jp {
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
    
    static let url = "url"
    static let overrideScreenLock = "overrideScreenLock"
    static let disabled = "disabled"
    static let uuid = "uuid"
    
    static let configurationJSON = "configurationJSON"
    static let socketJSON = "socketJSON"
    
    
    
    static let status = "status"
    static let name = "name"
    static let version = "version"
    static let serverTime = "serverTime"
    static let apiEnabled = "apiEnabled"
    static let careportalEnabled = "careportalEnabled"
    static let boluscalcEnabled = "boluscalcEnabled"
    static let head = "head"

    static let settings = "settings"
    static let units = "units"
    static let timeFormat = "timeFormat"
    static let nightMode = "nightMode"
    static let editMode = "editMode"
    static let showRawbg = "showRawbg"
    
    static let customTitle = "customTitle"
    static let theme = "theme"
    static let alarmUrgentHigh = "alarmUrgentHigh"
    static let alarmHigh = "alarmHigh"
    static let alarmLow = "alarmLow"
    static let alarmUrgentLow = "alarmUrgentLow"

}


extension Site {
    
    func siteJSON(config: JSON?, socket: JSON?) -> JSON {
        
        guard let config = config, socket = socket else {
            return [jp.url : url, jp.overrideScreenLock : overrideScreenLock, jp.disabled: disabled, jp.uuid: uuid]
        }
        
        let json: JSON = [jp.url : url, jp.overrideScreenLock : overrideScreenLock, jp.disabled: disabled, jp.uuid: uuid, jp.configurationJSON: config.dictionaryObject!, jp.socketJSON: socket.dictionaryObject!]
        
        return json
    }
    
    
    mutating func parseJSONforSite(json: JSON) {
        let url = json[jp.url].URL ?? NSURL()
        let overrideScreenLock = json[jp.overrideScreenLock].bool ?? false
        let disabled = json[jp.disabled].bool ?? false
        let configurationJSON = json[jp.configurationJSON] ?? JSON(["error" : "configurationJSON"])
        let socketJSON = json[jp.socketJSON] ??  JSON(["error" : "socketJSON"])
        let uuid = NSUUID(UUIDString: json[jp.uuid].stringValue) ?? NSUUID()
        
        
        self.url = url
        self.overrideScreenLock = overrideScreenLock
        self.disabled = disabled
        self.uuid = uuid
        
        parseJSONforConfiugration(configurationJSON)
        parseJSONforSocketData(socketJSON)
    }
    

    mutating func parseJSONforConfiugration(json: JSON) {
        
        let settingsJSON = json[jp.settings]
        
        let units = Units(rawValue: settingsJSON[jp.units].stringValue) ?? .Mmol
        let timeFormat = settingsJSON[jp.timeFormat].int ?? 12
        let nightMode = settingsJSON[jp.nightMode].bool ?? false
        let editMode = settingsJSON[jp.editMode].bool ?? true
        let showRawbg = RawBGMode(rawValue: settingsJSON[jp.showRawbg].stringValue) ?? .Never
        let customtitle = settingsJSON[jp.customTitle].string ?? "Unknown"
        let theme = settingsJSON[jp.theme].string ?? "color"
        
        
        let alarmUrgentHigh = settingsJSON[jp.alarmUrgentHigh].bool ?? true
        let alarmHigh = settingsJSON[jp.alarmHigh].bool ?? true
        let alarmLow = settingsJSON[jp.alarmLow].bool ?? true
        let alarmUrgentLow = settingsJSON[jp.alarmUrgentLow].bool ?? true
        
        let placeholderAlarm1 = [15, 30, 45, 60]
        let placeholderAlarm2 = [30, 60, 90, 120]
        
        let alarmUrgentHighMins: [Int] = settingsJSON["alarmUrgentHighMins"].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmHighMins: [Int] = settingsJSON["alarmHighMins"].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmLowMins: [Int] = settingsJSON["alarmLowMins"].arrayValue.map { $0.int! } ?? placeholderAlarm1
        let alarmUrgentLowMins: [Int] = settingsJSON["alarmUrgentLowMins"].arrayValue.map { $0.int! } ?? placeholderAlarm1
        
        let alarmWarnMins: [Int] = settingsJSON["alarmWarnMins"].arrayValue.map { $0.int! } ?? placeholderAlarm2
        
        let alarmTimeagoWarn = settingsJSON["alarmTimeagoWarn"].bool ?? true
        let alarmTimeagoWarnMins = (settingsJSON["alarmTimeagoWarnMins"].double ?? 15) * 60
        
        let alarmTimeagoUrgent = settingsJSON["alarmTimeagoUrgent"].bool ?? true
        let alarmTimeagoUrgentMins = (settingsJSON["alarmTimeagoUrgentMins"].double ?? 30) * 60
        
        let language = settingsJSON["language"].string ?? "en"
        let scaleY = settingsJSON["scaleY"].string ?? "log"
        
        
        let enabled: [ShowPlugins] = settingsJSON["enable"].arrayValue.flatMap { ShowPlugins(rawValue: $0.stringValue) }
        
        
        let thresholdsJSON = settingsJSON["thresholds"]
        let thresholds = Thresholds(bgHigh: thresholdsJSON["bgHigh"].doubleValue, bgLow: thresholdsJSON["bgLow"].doubleValue, bgTargetBottom: thresholdsJSON["bgTargetBottom"].doubleValue, bgTargetTop: thresholdsJSON["bgTargetTop"].doubleValue)
        
        let alarmType = AlarmType(rawValue: settingsJSON["alarmType"].stringValue) ?? .simple
        let hreartbeat = settingsJSON["heartbeat"].int ?? 60
        let baseURL = settingsJSON["baseURL"].stringValue
        
        let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
        
        let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
        
        let settings = Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: hreartbeat)
        
        let serverConfiguration = ServerConfiguration(status: json[jp.status].stringValue, version: json[jp.version].stringValue, name: json[jp.name].stringValue, serverTime: json[jp.serverTime].stringValue, api: json[jp.apiEnabled].boolValue, carePortal: json[jp.careportalEnabled].boolValue , boluscalc: json[jp.boluscalcEnabled].boolValue, settings: settings, head: json[jp.head].stringValue)
        self.configuration = serverConfiguration
    }
    
    mutating func parseJSONforSocketData(json: JSON) {
        
        if let lastUpdated = json[jp.lastUpdated].double {
            // print(lastUpdated)
            self.milliseconds = lastUpdated
        }
        
        if let uploaderBattery = json[jp.devicestatus][jp.uploaderBattery].int {
            self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: 0))
        }
        
        let deviceStatus = json[jp.devicestatus]
        
        for (_, subJson) in deviceStatus {
            print(subJson.description)
            if let mills = subJson[jp.mills].double {
                if let uploaderBattery = subJson[jp.uploader, jp.battery].int {
                    self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills))
                }
            }
        }
    
        let sgvs = json[jp.sgvs]
        for (_, subJson) in sgvs {
            if let deviceString = subJson[jp.device].string, rssi = subJson[jp.rssi].int, unfiltered = subJson[jp.unfiltered].double, directionString = subJson[jp.direction].string, filtered = subJson[jp.filtered].double, noiseInt = subJson[jp.noise].int, mills = subJson[jp.mills].double, mgdl = subJson[jp.mgdl].double {
                
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let direction = Direction(rawValue: directionString) ?? Direction.None
                let noise = Noise(rawValue: noiseInt) ?? Noise()
                
                let sensorValue = SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mills)
                
                
                self.sgvs.append(sensorValue)
                // print(sensorValue)
            }
        }
        
        let mbgs = json[jp.mbgs]
        for (_, subJson) in mbgs {
            if let deviceString = subJson[jp.device].string, mills = subJson[jp.mills].double, mgdl = subJson[jp.mgdl].double {
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                
                let meter = MeteredGlucoseValue(milliseconds: mills, device: device, mgdl: mgdl)
                self.mbgs.append(meter)
                // print(meter)
            }
        }
        
        let cals = json[jp.cals]
        for (_, subJson) in cals {
            if let slope = subJson[jp.slope].double, intercept = subJson[jp.intercept].double, scale = subJson[jp.scale].double, mills = subJson[jp.mills].double {
                
                let calibration = Calibration(slope: slope, intercept: intercept, scale: scale, milliseconds: mills)
                
                self.cals.append(calibration)
                // print(calibration)
            }
        }
        // print(site)
        
        // makes sure things are sorted correctly by date. When delta's come in they might screw up the order.
        self.sgvs.sortInPlace{(item1:SensorGlucoseValue, item2:SensorGlucoseValue) -> Bool in
            item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
        }
        self.cals.sortInPlace{(item1:Calibration, item2:Calibration) -> Bool in
            item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
        }
        self.mbgs.sortInPlace{(item1:MeteredGlucoseValue, item2:MeteredGlucoseValue) -> Bool in
            item1.date.compare(item2.date) == NSComparisonResult.OrderedDescending
        }
    }
}