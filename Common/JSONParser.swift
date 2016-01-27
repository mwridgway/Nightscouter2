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
    static let sgvs = "sgvs"
    static let mbgs = "mbgs"
    static let cals = "cals"
    static let deltaCount = "delta"
    static let profiles = "profiles"
    static let treatments = "treatments"
}

extension Site: Encodable {
    struct JSONKey {
        static let lastUpdated = "lastUpdated"
        static let url = "url"
        static let overrideScreenLock = "overrideScreenLock"
        static let disabled = "disabled"
        static let uuid = "uuid"
        static let configuration = "configuration"
        static let data = "data"
    }
    
    func encode() -> [String: AnyObject] {
        return [JSONKey.url : url.absoluteString, JSONKey.overrideScreenLock : overrideScreenLock, JSONKey.disabled: disabled, JSONKey.uuid: uuid.UUIDString, JSONKey.configuration: configuration?.encode() ?? ""]
    }
    
    static func decode(dict: [String: AnyObject]) -> Site? {
        
        guard let urlString = dict[JSONKey.url] as? String, url = NSURL(string: urlString), uuidString = dict[JSONKey.uuid] as? String, uuid = NSUUID(UUIDString: uuidString) else {
            return nil
        }
        
        var site = Site(url: url, uuid: uuid)
        
        site.overrideScreenLock = dict[JSONKey.overrideScreenLock] as? Bool ?? false
        site.disabled = dict[JSONKey.disabled] as? Bool ?? false
        
        site.configuration = ServerConfiguration.decode(dict[JSONKey.configuration] as! [String: AnyObject])
        
        return site
    }
}

extension ServerConfiguration: Encodable {
    struct JSONKey {
        static let status = "status"
        static let name = "name"
        static let version = "version"
        static let serverTime = "serverTime"
        static let apiEnabled = "apiEnabled"
        static let careportalEnabled = "careportalEnabled"
        static let boluscalcEnabled = "boluscalcEnabled"
        static let head = "head"
        static let settings = "settings"
    }
    
    func encode() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict[JSONKey.status] = status
        dict[JSONKey.apiEnabled] = apiEnabled
        dict[JSONKey.serverTime] = serverTime
        dict[JSONKey.careportalEnabled] = careportalEnabled
        dict[JSONKey.boluscalcEnabled] = boluscalcEnabled
        dict[JSONKey.settings] = settings?.encode()
        dict[JSONKey.head] = head
        dict[JSONKey.version] = version
        dict[JSONKey.name] = name
        
        return dict
    }
    
    static func decode(dict: [String: AnyObject]) -> ServerConfiguration? {
        
        guard let status = dict[JSONKey.status] as? String,
            apiEnabled = dict[JSONKey.apiEnabled] as? Bool,
            serverTime = dict[JSONKey.serverTime] as? String,
            careportalEnabled = dict[JSONKey.careportalEnabled] as? Bool,
            head = dict[JSONKey.head] as? String,
            version = dict[JSONKey.version] as? String,
            name = dict[JSONKey.name] as? String else {
                return nil
        }
        let boluscalcEnabled = dict[JSONKey.boluscalcEnabled] as? Bool ?? false
        
        var settings: Settings?
        
        // TODO: Decode dictionary into settings...
        if let settingsDict = dict[JSONKey.settings] as? [String: AnyObject]{
            settings = Settings.decode(settingsDict)
        }
        
        let config = ServerConfiguration(status: status, version: version, name: name, serverTime: serverTime, api: apiEnabled, carePortal: careportalEnabled, boluscalc: boluscalcEnabled, settings: settings, head: head)
        
        return config
    }
}

extension Settings: Encodable {
    struct JSONKey {
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
        static let alarmTypes = "alarmTypes"
        static let heartbeat = "heartbeat"
        static let baseURL = "baseURL"
        static let thresholds = "thresholds"
    }
    
    func encode() -> [String : AnyObject] {
        return [
            JSONKey.units: units.description,
            JSONKey.timeFormat: timeFormat,
            JSONKey.nightMode: nightMode,
            JSONKey.editMode: editMode,
            JSONKey.showRawbg: showRawbg.rawValue,
            JSONKey.customTitle: customTitle,
            JSONKey.theme: theme,
            JSONKey.alarmUrgentHigh: alarms.urgentHigh,
            JSONKey.alarmHigh: alarms.high,
            JSONKey.alarmLow: alarms.low,
            JSONKey.alarmUrgentLow: alarms.urgentLow,
            JSONKey.alarmUrgentHighMins: alarms.urgentHighMins,
            JSONKey.alarmHighMins: alarms.highMins,
            JSONKey.alarmLowMins: alarms.lowMins,
            JSONKey.alarmUrgentLowMins: alarms.urgentLowMins,
            JSONKey.language: language,
            JSONKey.scaleY: scaleY,
            JSONKey.enable : enable.flatMap { $0.rawValue },
            JSONKey.alarmTypes: alarmType.rawValue,
            JSONKey.heartbeat: heartbeat,
            JSONKey.baseURL: baseURL,
            JSONKey.thresholds: thresholds.encode()
        ]
    }
    
    static func decode(dict: [String: AnyObject]) -> Settings? {
        let json = JSON(dict)
        let units = Units(rawValue: json[Settings.JSONKey.units].stringValue) ?? .Mmol
        let timeFormat = json[Settings.JSONKey.timeFormat].int ?? 12
        let nightMode = json[Settings.JSONKey.nightMode].bool ?? false
        let editMode = json[Settings.JSONKey.editMode].bool ?? true
        let showRawbg = RawBGMode(rawValue: json[Settings.JSONKey.showRawbg].stringValue) ?? .Never
        let customtitle = json[Settings.JSONKey.customTitle].string ?? "Unknown"
        let theme = json[Settings.JSONKey.theme].string ?? "color"
        let alarmUrgentHigh = json[Settings.JSONKey.alarmUrgentHigh].bool ?? true
        let alarmHigh = json[Settings.JSONKey.alarmHigh].bool ?? true
        let alarmLow = json[Settings.JSONKey.alarmLow].bool ?? true
        let alarmUrgentLow = json[Settings.JSONKey.alarmUrgentLow].bool ?? true
        let placeholderAlarm1 = [15, 30, 45, 60]
        let placeholderAlarm2 = [30, 60, 90, 120]
        let alarmUrgentHighMins: [Int] = json[Settings.JSONKey.alarmUrgentHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmHighMins: [Int] = json[Settings.JSONKey.alarmHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        let alarmLowMins: [Int] = json[Settings.JSONKey.alarmLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
        let alarmUrgentLowMins: [Int] = json[Settings.JSONKey.alarmUrgentLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
        
        let alarmWarnMins: [Int] = json[Settings.JSONKey.alarmWarnMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
        
        let alarmTimeagoWarn = json[Settings.JSONKey.alarmTimeagoWarn].bool ?? true
        let alarmTimeagoWarnMins = (json[Settings.JSONKey.alarmTimeagoWarnMins].double ?? 15) * 60
        
        let alarmTimeagoUrgent = json[Settings.JSONKey.alarmTimeagoUrgent].bool ?? true
        let alarmTimeagoUrgentMins = (json[Settings.JSONKey.alarmTimeagoUrgentMins].double ?? 30) * 60
        
        let language = json[Settings.JSONKey.language].string ?? "en"
        let scaleY = json[Settings.JSONKey.scaleY].string ?? "log"
        
        let enabled: [Plugin] = json[Settings.JSONKey.enable].arrayValue.flatMap {
            Plugin(rawValue: $0.stringValue)
        }
        
        let thresholdsJSON = json[Settings.JSONKey.thresholds]
        let thresholds = Thresholds(bgHigh: thresholdsJSON[Thresholds.JSONKey.bgHigh].doubleValue, bgLow: thresholdsJSON[Thresholds.JSONKey.bgLow].doubleValue, bgTargetBottom: thresholdsJSON[Thresholds.JSONKey.bgTargetBottom].doubleValue, bgTargetTop: thresholdsJSON[Thresholds.JSONKey.bgTargetTop].doubleValue)
        
        let alarmType = AlarmType(rawValue: json[Settings.JSONKey.alarmTypes].stringValue) ?? .simple
        let hreartbeat = json[Settings.JSONKey.heartbeat].int ?? 60
        let baseURL = json[Settings.JSONKey.baseURL].stringValue
        
        let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
        
        let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
        
        let settings = Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: hreartbeat)
        
        return settings
        
        /*
        guard let unitsString = dict[JSONKey.units] as? String,
        timeFormat = dict[JSONKey.timeFormat] as? Int,
        enabledStrings = dict[JSONKey.enable] as? [String],
        thresholdsDict = dict[JSONKey.thresholds] as? [String: AnyObject],
        heartbeatInt = dict[JSONKey.heartbeat] as? Int,
        alarmTypeString = dict[JSONKey.alarmTypes] as? [String],
        baseURL = dict[JSONKey.baseURL] as? String,
        customtitle = dict[JSONKey.customTitle] as? String,
        showRawbgString = dict[JSONKey.showRawbg] as? String,
        nightMode = dict[JSONKey.nightMode] as? Bool,
        editMode = dict[JSONKey.editMode] as? Bool,
        theme = dict[JSONKey.theme] as? String,
        alarmUrgentHigh = dict[JSONKey.alarmUrgentHigh] as? Bool,
        alarmUrgentHighMins = dict[JSONKey.alarmUrgentHighMins] as? [Int],
        alarmWarnMins = dict[JSONKey.alarmWarnMins] as? [Int],
        alarmUrgentLow = dict[JSONKey.alarmUrgentLow] as? Bool,
        alarmUrgentLowMins = dict[JSONKey.alarmUrgentLowMins] as? [Int],
        alarmHigh = dict[JSONKey.alarmHigh] as? Bool,
        alarmHighMins = dict[JSONKey.alarmHighMins] as? [Int],
        alarmLow = dict[JSONKey.alarmLow] as? Bool,
        alarmLowMins = dict[JSONKey.alarmLowMins] as? [Int],
        alarmTimeagoWarn = dict[JSONKey.alarmTimeagoWarn] as? Bool,
        alarmTimeagoWarnMins = dict[JSONKey.alarmTimeagoWarnMins] as? Double,
        alarmTimeagoUrgent = dict[JSONKey.alarmTimeagoUrgent] as? Bool,
        alarmTimeagoUrgentMins = dict[JSONKey.alarmTimeagoUrgentMins] as? Double,
        scaleY = dict[JSONKey.scaleY] as? String,
        language = dict[JSONKey.language] as? String else {
        return nil
        }
        
        let units = Units(rawValue: unitsString) ?? .Mgdl
        let showRawbg = RawBGMode(rawValue: showRawbgString) ?? .Never
        let enabled: [Plugin] = enabledStrings.flatMap {
        Plugin(rawValue: $0)
        }
        
        let thresholds = Thresholds.decode(thresholdsDict) ?? Thresholds(bgHigh: 300, bgLow: 70, bgTargetBottom: 60, bgTargetTop: 250)
        let alarmType = AlarmType(rawValue: alarmTypeString[0]) ?? .simple
        
        let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
        
        let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
        
        return Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: heartbeatInt)
        */
    }
}

extension Thresholds: Encodable {
    struct JSONKey {
        static let bgHigh = "bgHigh"
        static let bgLow = "bgLow"
        static let bgTargetBottom = "bgTargetBottom"
        static let bgTargetTop = "bgTargetTop"
    }
    
    func encode() -> [String : AnyObject] {
        return [
            JSONKey.bgHigh: bgHigh,
            JSONKey.bgLow: bgLow,
            JSONKey.bgTargetBottom: targetBottom,
            JSONKey.bgTargetTop: targetTop
        ]
    }
    
    static func decode(dict: [String: AnyObject]) -> Thresholds? {
        guard let bgHigh = dict[JSONKey.bgHigh] as? Double, bgLow =  dict[JSONKey.bgLow] as? Double, bgTargetBottom =  dict[JSONKey.bgTargetBottom] as? Double, bgTargetTop =  dict[JSONKey.bgTargetTop] as? Double else {
            return nil
        }
        
        return Thresholds(bgHigh: bgHigh, bgLow: bgLow, bgTargetBottom: bgTargetBottom, bgTargetTop: bgTargetTop)
    }
}

extension Calibration: Encodable {
    struct JSONKey {
        static let slope = "slope"
        static let intercept = "intercept"
        static let scale = "scale"
        static let mills = "mills"
    }
    func encode() -> [String : AnyObject] {
        return [JSONKey.slope : slope, JSONKey.intercept: intercept, JSONKey.mills: milliseconds, JSONKey.scale: scale, JSONKey.slope: slope]
    }
}

extension MeteredGlucoseValue: Encodable {
    struct JSONKey {
        static let mills = "mills"
        static let device = "device"
        static let mgdl = "mgdl"
    }
    
    func encode() -> [String : AnyObject] {
        return [JSONKey.mills: milliseconds, JSONKey.mgdl: mgdl, JSONKey.device: device.description]
    }
}

extension SensorGlucoseValue: Encodable {
    struct JSONKey {
        static let device = "device"
        static let rssi = "rssi"
        static let filtered = "filtered"
        static let unfiltered = "unfiltered"
        static let direction = "direction"
        static let noise = "noise"
        static let mills = "mills"
        static let mgdl = "mgdl"
    }
    
    func encode() -> [String : AnyObject] {
        return [JSONKey.device: device.description, JSONKey.direction: direction.description, JSONKey.filtered: filtered, JSONKey.mills: milliseconds, JSONKey.noise: noise.description, JSONKey.rssi: rssi, JSONKey.unfiltered: unfiltered, JSONKey.mgdl: mgdl]
    }
}

extension DeviceStatus: Encodable {
    struct JSONKey {
        static let devicestatus = "devicestatus"
        static let mills = "mills"
        static let uploader = "uploader"
        static let uploaderBattery = "uploaderBattery"
        
        static let battery = "battery"
    }
    
    func encode() -> [String : AnyObject] {
        return [JSONKey.mills: milliseconds, JSONKey.uploader: uploaderBattery]
    }
}
















/*
extension Site {
func siteJSON(config: JSON?, socket: JSON?) -> JSON {

guard let config = config, socket = socket else {
return [JSONKey.url : url, JSONKey.overrideScreenLock : overrideScreenLock, JSONKey.disabled: disabled, JSONKey.uuid: uuid]
}

let json: JSON = [JSONKey.url : url, JSONKey.overrideScreenLock : overrideScreenLock, JSONKey.disabled: disabled, JSONKey.uuid: uuid, JSONKey.configuration: config.dictionaryObject!, JSONKey.data: socket.dictionaryObject!]

return json
}
}
*/

extension Site {
    //
    //    mutating func parseJSONforSite(json: JSON) {
    //        let url = json[JSONKey.url].URL ?? NSURL()
    //        let overrideScreenLock = json[JSONKey.overrideScreenLock].bool ?? false
    //        let disabled = json[JSONKey.disabled].bool ?? false
    //        let configurationJSON = json[JSONKey.configuration] ?? JSON(["error" : "configuration"])
    //        let socketJSON = json[JSONKey.data] ??  JSON(["error" : "data"])
    //        let uuid = NSUUID(UUIDString: json[JSONKey.uuid].stringValue) ?? NSUUID()
    //
    //
    //        self.url = url
    //        self.overrideScreenLock = overrideScreenLock
    //        self.disabled = disabled
    //        self.uuid = uuid
    //
    //        parseJSONforConfiugration(configurationJSON)
    //        parseJSONforSocketData(socketJSON)
    //    }
    /*
    mutating func parseJSONforConfiugration(json: JSON) {
    
    let settingsJSON = json[ServerConfiguration.JSONKey.settings]
    let units = Units(rawValue: settingsJSON[Settings.JSONKey.units].stringValue) ?? .Mmol
    let timeFormat = settingsJSON[Settings.JSONKey.timeFormat].int ?? 12
    let nightMode = settingsJSON[Settings.JSONKey.nightMode].bool ?? false
    let editMode = settingsJSON[Settings.JSONKey.editMode].bool ?? true
    let showRawbg = RawBGMode(rawValue: settingsJSON[Settings.JSONKey.showRawbg].stringValue) ?? .Never
    let customtitle = settingsJSON[Settings.JSONKey.customTitle].string ?? "Unknown"
    let theme = settingsJSON[Settings.JSONKey.theme].string ?? "color"
    let alarmUrgentHigh = settingsJSON[Settings.JSONKey.alarmUrgentHigh].bool ?? true
    let alarmHigh = settingsJSON[Settings.JSONKey.alarmHigh].bool ?? true
    let alarmLow = settingsJSON[Settings.JSONKey.alarmLow].bool ?? true
    let alarmUrgentLow = settingsJSON[Settings.JSONKey.alarmUrgentLow].bool ?? true
    let placeholderAlarm1 = [15, 30, 45, 60]
    let placeholderAlarm2 = [30, 60, 90, 120]
    let alarmUrgentHighMins: [Int] = settingsJSON[Settings.JSONKey.alarmUrgentHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
    let alarmHighMins: [Int] = settingsJSON[Settings.JSONKey.alarmHighMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
    let alarmLowMins: [Int] = settingsJSON[Settings.JSONKey.alarmLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
    let alarmUrgentLowMins: [Int] = settingsJSON[Settings.JSONKey.alarmUrgentLowMins].arrayValue.map { $0.int! } ?? placeholderAlarm1
    
    let alarmWarnMins: [Int] = settingsJSON[Settings.JSONKey.alarmWarnMins].arrayValue.map { $0.int! } ?? placeholderAlarm2
    
    let alarmTimeagoWarn = settingsJSON[Settings.JSONKey.alarmTimeagoWarn].bool ?? true
    let alarmTimeagoWarnMins = (settingsJSON[Settings.JSONKey.alarmTimeagoWarnMins].double ?? 15) * 60
    
    let alarmTimeagoUrgent = settingsJSON[Settings.JSONKey.alarmTimeagoUrgent].bool ?? true
    let alarmTimeagoUrgentMins = (settingsJSON[Settings.JSONKey.alarmTimeagoUrgentMins].double ?? 30) * 60
    
    let language = settingsJSON[Settings.JSONKey.language].string ?? "en"
    let scaleY = settingsJSON[Settings.JSONKey.scaleY].string ?? "log"
    
    let enabled: [Plugin] = settingsJSON[Settings.JSONKey.enable].arrayValue.flatMap {
    Plugin(rawValue: $0.stringValue)
    }
    
    let thresholdsJSON = settingsJSON[Settings.JSONKey.thresholds]
    let thresholds = Thresholds(bgHigh: thresholdsJSON[Thresholds.JSONKey.bgHigh].doubleValue, bgLow: thresholdsJSON[Thresholds.JSONKey.bgLow].doubleValue, bgTargetBottom: thresholdsJSON[Thresholds.JSONKey.bgTargetBottom].doubleValue, bgTargetTop: thresholdsJSON[Thresholds.JSONKey.bgTargetTop].doubleValue)
    
    let alarmType = AlarmType(rawValue: settingsJSON[Settings.JSONKey.alarmTypes].stringValue) ?? .simple
    let hreartbeat = settingsJSON[Settings.JSONKey.heartbeat].int ?? 60
    let baseURL = settingsJSON[Settings.JSONKey.baseURL].stringValue
    
    let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
    
    let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
    
    let settings = Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: hreartbeat)
    
    let serverConfiguration = ServerConfiguration(status: json[ServerConfiguration.JSONKey.status].stringValue, version: json[ServerConfiguration.JSONKey.version].stringValue, name: json[ServerConfiguration.JSONKey.name].stringValue, serverTime: json[ServerConfiguration.JSONKey.serverTime].stringValue, api: json[ServerConfiguration.JSONKey.apiEnabled].boolValue, carePortal: json[ServerConfiguration.JSONKey.careportalEnabled].boolValue , boluscalc: json[ServerConfiguration.JSONKey.boluscalcEnabled].boolValue, settings: settings, head: json[ServerConfiguration.JSONKey.head].stringValue)
    
    self.configuration = serverConfiguration
    }
    */
    
    mutating func parseJSONforSocketData(json: JSON) {
        
        if let lastUpdated = json[Site.JSONKey.lastUpdated].double {
            self.milliseconds = lastUpdated
        }
        
        if let uploaderBattery = json[DeviceStatus.JSONKey.devicestatus][DeviceStatus.JSONKey.uploaderBattery].int {
            self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: 0))
        }
        
        let deviceStatus = json[DeviceStatus.JSONKey.devicestatus]
        for (_, subJson) in deviceStatus {
            print(subJson.description)
            if let mills = subJson[DeviceStatus.JSONKey.mills].double {
                if let uploaderBattery = subJson[DeviceStatus.JSONKey.uploader, DeviceStatus.JSONKey.battery].int {
                    self.deviceStatus.append(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills))
                }
            }
        }
        
        let sgvs = json[JSONPropertyKey.sgvs]
        print("sgv count: \(sgvs.count)")
        
        for (_, subJson) in sgvs {
            // print("working on sgv[\(index)]")
            
            if let deviceString = subJson[SensorGlucoseValue.JSONKey.device].string, rssi = subJson[SensorGlucoseValue.JSONKey.rssi].int, unfiltered = subJson[SensorGlucoseValue.JSONKey.unfiltered].double, directionString = subJson[SensorGlucoseValue.JSONKey.direction].string, filtered = subJson[SensorGlucoseValue.JSONKey.filtered].double, noiseInt = subJson[SensorGlucoseValue.JSONKey.noise].int, mills = subJson[SensorGlucoseValue.JSONKey.mills].double, mgdl = subJson[SensorGlucoseValue.JSONKey.mgdl].double {
                
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let direction = Direction(rawValue: directionString) ?? Direction.None
                let noise = Noise(rawValue: noiseInt) ?? Noise()
                
                let sensorValue = SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mills)
                self.sgvs.append(sensorValue)
            }
        }
        
        let mbgs = json[JSONPropertyKey.mbgs]
        print("mbgs count: \(mbgs.count)")
        
        for (_, subJson) in mbgs {
            if let deviceString = subJson[MeteredGlucoseValue.JSONKey.device].string, mills = subJson[MeteredGlucoseValue.JSONKey.mills].double, mgdl = subJson[MeteredGlucoseValue.JSONKey.mgdl].double {
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let meter = MeteredGlucoseValue(milliseconds: mills, device: device, mgdl: mgdl)
                self.mbgs.append(meter)
            }
        }
        
        let cals = json[JSONPropertyKey.cals]
        print("cals count: \(cals.count)")
        
        for (_, subJson) in cals {
            if let slope = subJson[Calibration.JSONKey.slope].double, intercept = subJson[Calibration.JSONKey.intercept].double, scale = subJson[Calibration.JSONKey.scale].double, mills = subJson[Calibration.JSONKey.mills].double {
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