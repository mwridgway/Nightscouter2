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
struct JSONPropertyKey {
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
    static let alarmUrgentHighMins = "alarmUrgentHighMins"
    static let alarmHighMins = "alarmHighMins"
    static let alarmLowMins = "alarmLowMins"
    static let alarmUrgentLowMins = "alarmUrgentLowMins"
    static let alarmWarnMins = "alarmWarnMins"
    static let alarmTimeagoWarn = "alarmTimeagoWarn"
    static let alarmTimeagoWarnMins = "alarmTimeagoWarnMins"
    static let alarmTimeagoUrgent = "alarmTimeagoUrgent"
    static let alarmTimeagoUrgentMins = "alarmTimeagoUrgentMins"
    static let language = "language"
    static let scaleY = "scaleY"
    static let enable = "enable"
    static let thresholds = "thresholds"
    static let bgHigh = "bgHigh"
    static let bgLow = "bgLow"
    static let bgTargetBottom = "bgTargetBottom"
    static let bgTargetTop = "bgTargetTop"
    static let alarmType = "alarmType"
    static let heartbeat = "heartbeat"
    static let baseURL = "baseURL"
}


extension Site: Encodable {
    
    func encode() -> [String: AnyObject] {
        return [JSONPropertyKey.url : url, JSONPropertyKey.overrideScreenLock : overrideScreenLock, JSONPropertyKey.disabled: disabled, JSONPropertyKey.uuid: uuid]
    }
    
    func siteJSON(config: JSON?, socket: JSON?) -> JSON {
        
        guard let config = config, socket = socket else {
            return [JSONPropertyKey.url : url, JSONPropertyKey.overrideScreenLock : overrideScreenLock, JSONPropertyKey.disabled: disabled, JSONPropertyKey.uuid: uuid]
        }
        
        let json: JSON = [JSONPropertyKey.url : url, JSONPropertyKey.overrideScreenLock : overrideScreenLock, JSONPropertyKey.disabled: disabled, JSONPropertyKey.uuid: uuid, JSONPropertyKey.configurationJSON: config.dictionaryObject!, JSONPropertyKey.socketJSON: socket.dictionaryObject!]
        
        return json
    }
}
extension Site {

    mutating func parseJSONforSite(json: JSON) {
        let url = json[JSONPropertyKey.url].URL ?? NSURL()
        let overrideScreenLock = json[JSONPropertyKey.overrideScreenLock].bool ?? false
        let disabled = json[JSONPropertyKey.disabled].bool ?? false
        let configurationJSON = json[JSONPropertyKey.configurationJSON] ?? JSON(["error" : "configurationJSON"])
        let socketJSON = json[JSONPropertyKey.socketJSON] ??  JSON(["error" : "socketJSON"])
        let uuid = NSUUID(UUIDString: json[JSONPropertyKey.uuid].stringValue) ?? NSUUID()
        
        
        self.url = url
        self.overrideScreenLock = overrideScreenLock
        self.disabled = disabled
        self.uuid = uuid
        
        parseJSONforConfiugration(configurationJSON)
        parseJSONforSocketData(socketJSON)
    }
    
    mutating func parseJSONforConfiugration(json: JSON) {
        
        let settingsJSON = json[JSONPropertyKey.settings]
        let units = Units(rawValue: settingsJSON[JSONPropertyKey.units].stringValue) ?? .Mmol
        let timeFormat = settingsJSON[JSONPropertyKey.timeFormat].int ?? 12
        let nightMode = settingsJSON[JSONPropertyKey.nightMode].bool ?? false
        let editMode = settingsJSON[JSONPropertyKey.editMode].bool ?? true
        let showRawbg = RawBGMode(rawValue: settingsJSON[JSONPropertyKey.showRawbg].stringValue) ?? .Never
        let customtitle = settingsJSON[JSONPropertyKey.customTitle].string ?? "Unknown"
        let theme = settingsJSON[JSONPropertyKey.theme].string ?? "color"
        let alarmUrgentHigh = settingsJSON[JSONPropertyKey.alarmUrgentHigh].bool ?? true
        let alarmHigh = settingsJSON[JSONPropertyKey.alarmHigh].bool ?? true
        let alarmLow = settingsJSON[JSONPropertyKey.alarmLow].bool ?? true
        let alarmUrgentLow = settingsJSON[JSONPropertyKey.alarmUrgentLow].bool ?? true
        let placeholderAlarm1 = [15, 30, 45, 60]
        let placeholderAlarm2 = [30, 60, 90, 120]
        let alarmUrgentHighMins: [Int] = settingsJSON[JSONPropertyKey.alarmUrgentHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmHighMins: [Int] = settingsJSON[JSONPropertyKey.alarmHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmLowMins: [Int] = settingsJSON[JSONPropertyKey.alarmLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
        let alarmUrgentLowMins: [Int] = settingsJSON[JSONPropertyKey.alarmUrgentLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
        
        let alarmWarnMins: [Int] = settingsJSON[JSONPropertyKey.alarmWarnMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        
        let alarmTimeagoWarn = settingsJSON[JSONPropertyKey.alarmTimeagoWarn].bool ?? true
        let alarmTimeagoWarnMins = (settingsJSON[JSONPropertyKey.alarmTimeagoWarnMins].double ?? 15) * 60
        
        let alarmTimeagoUrgent = settingsJSON[JSONPropertyKey.alarmTimeagoUrgent].bool ?? true
        let alarmTimeagoUrgentMins = (settingsJSON[JSONPropertyKey.alarmTimeagoUrgentMins].double ?? 30) * 60
        
        let language = settingsJSON[JSONPropertyKey.language].string ?? "en"
        let scaleY = settingsJSON[JSONPropertyKey.scaleY].string ?? "log"
        
        let enabled: [ShowPlugins] = settingsJSON[JSONPropertyKey.enable].arrayValue.flatMap {
            ShowPlugins(rawValue: $0.stringValue)
        }
        
        let thresholdsJSON = settingsJSON[JSONPropertyKey.thresholds]
        let thresholds = Thresholds(bgHigh: thresholdsJSON[JSONPropertyKey.bgHigh].doubleValue, bgLow: thresholdsJSON[JSONPropertyKey.bgLow].doubleValue, bgTargetBottom: thresholdsJSON[JSONPropertyKey.bgTargetBottom].doubleValue, bgTargetTop: thresholdsJSON[JSONPropertyKey.bgTargetTop].doubleValue)
        
        let alarmType = AlarmType(rawValue: settingsJSON[JSONPropertyKey.alarmType].stringValue) ?? .simple
        let hreartbeat = settingsJSON[JSONPropertyKey.heartbeat].int ?? 60
        let baseURL = settingsJSON[JSONPropertyKey.baseURL].stringValue
        
        let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
        
        let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
        
        let settings = Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: hreartbeat)
        
        let serverConfiguration = ServerConfiguration(status: json[JSONPropertyKey.status].stringValue, version: json[JSONPropertyKey.version].stringValue, name: json[JSONPropertyKey.name].stringValue, serverTime: json[JSONPropertyKey.serverTime].stringValue, api: json[JSONPropertyKey.apiEnabled].boolValue, carePortal: json[JSONPropertyKey.careportalEnabled].boolValue , boluscalc: json[JSONPropertyKey.boluscalcEnabled].boolValue, settings: settings, head: json[JSONPropertyKey.head].stringValue)
        
        self.configuration = serverConfiguration
    }
    
    mutating func parseJSONforSocketData(json: JSON) {
        
        if let lastUpdated = json[JSONPropertyKey.lastUpdated].double {
            self.milliseconds = lastUpdated
        }
        
        if let uploaderBattery = json[JSONPropertyKey.devicestatus][JSONPropertyKey.uploaderBattery].int {
            self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: 0))
        }
        
        let deviceStatus = json[JSONPropertyKey.devicestatus]
        for (_, subJson) in deviceStatus {
            print(subJson.description)
            if let mills = subJson[JSONPropertyKey.mills].double {
                if let uploaderBattery = subJson[JSONPropertyKey.uploader, JSONPropertyKey.battery].int {
                    self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills))
                }
            }
        }
        
        let sgvs = json[JSONPropertyKey.sgvs]
        for (_, subJson) in sgvs {
            if let deviceString = subJson[JSONPropertyKey.device].string, rssi = subJson[JSONPropertyKey.rssi].int, unfiltered = subJson[JSONPropertyKey.unfiltered].double, directionString = subJson[JSONPropertyKey.direction].string, filtered = subJson[JSONPropertyKey.filtered].double, noiseInt = subJson[JSONPropertyKey.noise].int, mills = subJson[JSONPropertyKey.mills].double, mgdl = subJson[JSONPropertyKey.mgdl].double {
                
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let direction = Direction(rawValue: directionString) ?? Direction.None
                let noise = Noise(rawValue: noiseInt) ?? Noise()
                
                let sensorValue = SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mills)
                self.sgvs.append(sensorValue)
            }
        }
        
        let mbgs = json[JSONPropertyKey.mbgs]
        for (_, subJson) in mbgs {
            if let deviceString = subJson[JSONPropertyKey.device].string, mills = subJson[JSONPropertyKey.mills].double, mgdl = subJson[JSONPropertyKey.mgdl].double {
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let meter = MeteredGlucoseValue(milliseconds: mills, device: device, mgdl: mgdl)
                self.mbgs.append(meter)
            }
        }
        
        let cals = json[JSONPropertyKey.cals]
        for (_, subJson) in cals {
            if let slope = subJson[JSONPropertyKey.slope].double, intercept = subJson[JSONPropertyKey.intercept].double, scale = subJson[JSONPropertyKey.scale].double, mills = subJson[JSONPropertyKey.mills].double {
                let calibration = Calibration(slope: slope, intercept: intercept, scale: scale, milliseconds: mills)
                self.cals.append(calibration)
            }
        }
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