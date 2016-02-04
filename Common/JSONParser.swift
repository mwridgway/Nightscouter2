//
//  JSONParser.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/20/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

// All the Additions for JSON Processing happens here.

import Foundation
import SwiftyJSON

// All the JSON keys I saw when parsing the socket.io output for dataUpdate

struct GlobalJSONKey {
    static let sgvs = "sgvs"
    static let mbgs = "mbgs"
    static let cals = "cals"
    // static let deltaCount = "delta"
    // static let profiles = "profiles"
    // static let treatments = "treatments"
}

extension Site: Encodable, Decodable {
    struct JSONKey {
        static let lastUpdated = "lastUpdated"
        static let url = "url"
        static let overrideScreenLock = "overrideScreenLock"
        static let disabled = "disabled"
        static let uuid = "uuid"
        static let configuration = "configuration"
        static let data = "data"
        static let sgvs = "sgvs"
        static let mbgs = "mbgs"
        static let cals = "cals"
        static let deviceStatus = "deviceStatus"
    }
    
    func encode() -> [String: AnyObject] {
        let encodedSgvs: [[String : AnyObject]] = sgvs.flatMap{ $0.encode() }
         let encodedCals: [[String : AnyObject]] = cals.flatMap{ $0.encode() }
         let encodedMgbs: [[String : AnyObject]] = mbgs.flatMap{ $0.encode() }
        let encodedDeviceStatus: [[String : AnyObject]] = deviceStatus.flatMap{ $0.encode() }
        
        return [JSONKey.url : url.absoluteString, JSONKey.overrideScreenLock : overrideScreenLock, JSONKey.disabled: disabled, JSONKey.uuid: uuid.UUIDString, JSONKey.configuration: configuration?.encode() ?? "", JSONKey.sgvs: encodedSgvs, JSONKey.cals: encodedCals, JSONKey.mbgs: encodedMgbs, JSONKey.deviceStatus: encodedDeviceStatus]
    }
    
    static func decode(dict: [String: AnyObject]) -> Site? {
        
        guard let urlString = dict[JSONKey.url] as? String, url = NSURL(string: urlString), uuidString = dict[JSONKey.uuid] as? String, uuid = NSUUID(UUIDString: uuidString) else {
            return nil
        }
        
        var site = Site(url: url, uuid: uuid)
        site.overrideScreenLock = dict[JSONKey.overrideScreenLock] as? Bool ?? false
        site.disabled = dict[JSONKey.disabled] as? Bool ?? false
        
        let rootDictForData = dict
        
        if let sgvs = rootDictForData[JSONKey.sgvs] as? [[String: AnyObject]] {
            site.sgvs = sgvs.flatMap { SensorGlucoseValue.decode($0) }
        }
        if let mbgs = rootDictForData[JSONKey.mbgs] as? [[String: AnyObject]] {
            site.mbgs = mbgs.flatMap { MeteredGlucoseValue.decode($0) }
        }
        if let cals = rootDictForData[JSONKey.cals] as? [[String: AnyObject]] {
            site.cals = cals.flatMap { Calibration.decode($0) }
        }
        
        if let devStatus = rootDictForData[JSONKey.deviceStatus] as? [[String: AnyObject]] {
            site.deviceStatus = devStatus.flatMap { DeviceStatus.decode($0) }
        }
        
        if let config = dict[JSONKey.configuration] as? [String: AnyObject] {
            site.configuration = ServerConfiguration.decode(config)
        }
        
        return site
    }
}

extension ServerConfiguration: Encodable, Decodable {
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
        if let settingsDict = dict[JSONKey.settings] as? [String: AnyObject]{
            settings = Settings.decode(settingsDict)
        }
        
        let config = ServerConfiguration(status: status, version: version, name: name, serverTime: serverTime, api: apiEnabled, carePortal: careportalEnabled, boluscalc: boluscalcEnabled, settings: settings, head: head)
        
        return config
    }
}

extension Settings: Encodable, Decodable {
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
        let enabled: [Plugin] = json[Settings.JSONKey.enable].arrayValue.flatMap { Plugin(rawValue: $0.stringValue) }
        let thresholdsJSON = json[Settings.JSONKey.thresholds]
        let thresholds = Thresholds(bgHigh: thresholdsJSON[Thresholds.JSONKey.bgHigh].doubleValue, bgLow: thresholdsJSON[Thresholds.JSONKey.bgLow].doubleValue, bgTargetBottom: thresholdsJSON[Thresholds.JSONKey.bgTargetBottom].doubleValue, bgTargetTop: thresholdsJSON[Thresholds.JSONKey.bgTargetTop].doubleValue)
        let alarmType = AlarmType(rawValue: json[Settings.JSONKey.alarmTypes].stringValue) ?? .simple
        let hreartbeat = json[Settings.JSONKey.heartbeat].int ?? 60
        let baseURL = json[Settings.JSONKey.baseURL].stringValue
        let timeAgo = TimeAgoAlert(warn: alarmTimeagoWarn, warnMins: alarmTimeagoWarnMins, urgent: alarmTimeagoUrgent, urgentMins: alarmTimeagoUrgentMins)
        let alarms = Alarm(urgentHigh: alarmUrgentHigh, urgentHighMins: alarmUrgentHighMins, high: alarmHigh, highMins: alarmHighMins, low: alarmLow, lowMins: alarmLowMins, urgentLow: alarmUrgentLow, urgentLowMins: alarmUrgentLowMins, warnMins: alarmWarnMins)
        let settings = Settings(units: units, timeFormat: timeFormat, nightMode: nightMode, editMode: editMode, showRawbg: showRawbg, customTitle: customtitle, theme: theme, alarms: alarms, timeAgo: timeAgo, scaleY: scaleY, language: language, showPlugins: enabled, enable: enabled, thresholds: thresholds, baseURL: baseURL, alarmType: alarmType, heartbeat: hreartbeat)
        
        return settings
    }
}

extension Thresholds: Encodable, Decodable {
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

extension Calibration: Encodable, Decodable {
    struct JSONKey {
        static let slope = "slope"
        static let intercept = "intercept"
        static let scale = "scale"
        static let mills = "mills"
    }
    
    func encode() -> [String : AnyObject] {
        return [JSONKey.slope : slope, JSONKey.intercept: intercept, JSONKey.mills: milliseconds, JSONKey.scale: scale]
    }
    static func decode(dict: [String : AnyObject]) -> Calibration? {
        let json = JSON(dict)
        
        guard let slope = json[JSONKey.slope].double,
            intercept = json[JSONKey.intercept].double,
            scale = json[JSONKey.scale].double,
            mill = json[JSONKey.mills].double else {
            return nil
        }
        
        return Calibration(slope: slope, intercept: intercept, scale: scale, milliseconds: mill)
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
    
    static func decode(dict: [String : AnyObject]) -> MeteredGlucoseValue? {
        let json = JSON(dict)
        
        guard let deviceString = json[JSONKey.device].string, mgdl = json[JSONKey.mgdl].double, mill = json[JSONKey.mills].double else {
            return nil
        }
        
        let device = Device(rawValue: deviceString) ?? .Unknown
        
        return MeteredGlucoseValue(milliseconds: mill, device: device, mgdl: mgdl)
    }

}

extension SensorGlucoseValue: Encodable, Decodable {
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
        return [JSONKey.device: device.description, JSONKey.direction: direction.rawValue, JSONKey.filtered: filtered, JSONKey.mills: milliseconds, JSONKey.noise: noise.rawValue, JSONKey.rssi: rssi, JSONKey.unfiltered: unfiltered, JSONKey.mgdl: mgdl]
    }
    
    static func decode(dict: [String : AnyObject]) -> SensorGlucoseValue? {
        
        let json = JSON(dict)
        guard let deviceString = json[JSONKey.device].string, mgdl = json[JSONKey.mgdl].double, mill = json[JSONKey.mills].double, directionString = json[JSONKey.direction].string, rssi = json[JSONKey.rssi].int, unfiltered = json[JSONKey.unfiltered].double, filtered = json[JSONKey.filtered].double, noiseInt = json[JSONKey.noise].int else {
            return nil
        }
        
        let device = Device(rawValue: deviceString) ?? .Unknown
        let direction = Direction(rawValue: directionString) ?? .None
        let noise = Noise(rawValue: noiseInt) ?? .Unknown
        
        return SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mill)
    }
}

extension DeviceStatus: Encodable, Decodable {
    struct JSONKey {
        static let devicestatus = "devicestatus"
        static let mills = "mills"
        static let uploader = "uploader"
        static let uploaderBattery = "uploaderBattery"
        
        static let battery = "battery"
    }
    
    func encode() -> [String : AnyObject] {
        return [JSONKey.mills: milliseconds, JSONKey.uploaderBattery: uploaderBattery]
    }
    
    static func decode(dict: [String : AnyObject]) -> DeviceStatus? {
        let json = JSON(dict)
        
        guard let mills = json[JSONKey.mills].double, uploaderBattery = json[JSONKey.uploaderBattery].int else {
            return nil
        }
        
        return DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills)
    }
}

// MARK: Append incoming data from a socket.io connection.
extension Site {
    
    /**
     Mutates the current site by adding device, sgv, mbgs, cals received via JSON.
     
     - parameter json: JSON Data
     
     */
    mutating func parseJSONforSocketData(json: JSON) {
        
        if let lastUpdated = json[Site.JSONKey.lastUpdated].double {
            self.milliseconds = lastUpdated
        }
        
        if let uploaderBattery = json[DeviceStatus.JSONKey.devicestatus][DeviceStatus.JSONKey.uploaderBattery].int {
            self.deviceStatus.insertOrUpdate(DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: 0))
        }
        
        let deviceStatus = json[DeviceStatus.JSONKey.devicestatus]
        print("deviceStatus count: \(deviceStatus.count)")
        
        for (_, subJson) in deviceStatus {
            if let mills = subJson[DeviceStatus.JSONKey.mills].double {
                if let uploaderBattery = subJson[DeviceStatus.JSONKey.uploader, DeviceStatus.JSONKey.battery].int {
                    let dStatus = DeviceStatus(uploaderBattery: uploaderBattery, milliseconds: mills)
                    self.deviceStatus.insertOrUpdate(dStatus)
                }
            }
        }
        
        let sgvs = json[GlobalJSONKey.sgvs]
        print("sgv count: \(sgvs.count)")
        
        for (_, subJson) in sgvs {
            // print("working on sgv[\(index)]")
            
            if let deviceString = subJson[SensorGlucoseValue.JSONKey.device].string, rssi = subJson[SensorGlucoseValue.JSONKey.rssi].int, unfiltered = subJson[SensorGlucoseValue.JSONKey.unfiltered].double, directionString = subJson[SensorGlucoseValue.JSONKey.direction].string, filtered = subJson[SensorGlucoseValue.JSONKey.filtered].double, noiseInt = subJson[SensorGlucoseValue.JSONKey.noise].int, mills = subJson[SensorGlucoseValue.JSONKey.mills].double, mgdl = subJson[SensorGlucoseValue.JSONKey.mgdl].double {
                
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let direction = Direction(rawValue: directionString) ?? Direction.None
                let noise = Noise(rawValue: noiseInt) ?? Noise()
                
                let sensorValue = SensorGlucoseValue(direction: direction, device: device, rssi: rssi, unfiltered: unfiltered, filtered: filtered, mgdl: mgdl, noise: noise, milliseconds: mills)
                self.sgvs.insertOrUpdate(sensorValue)
            }
        }
        
        let mbgs = json[GlobalJSONKey.mbgs]
        print("mbgs count: \(mbgs.count)")
        
        for (_, subJson) in mbgs {
            if let deviceString = subJson[MeteredGlucoseValue.JSONKey.device].string, mills = subJson[MeteredGlucoseValue.JSONKey.mills].double, mgdl = subJson[MeteredGlucoseValue.JSONKey.mgdl].double {
                let device = Device(rawValue: deviceString) ?? Device.Unknown
                let meter = MeteredGlucoseValue(milliseconds: mills, device: device, mgdl: mgdl)
                self.mbgs.insertOrUpdate(meter)
            }
        }
        
        let cals = json[GlobalJSONKey.cals]
        print("cals count: \(cals.count)")
        
        for (_, subJson) in cals {
            if let slope = subJson[Calibration.JSONKey.slope].double, intercept = subJson[Calibration.JSONKey.intercept].double, scale = subJson[Calibration.JSONKey.scale].double, mills = subJson[Calibration.JSONKey.mills].double {
                let calibration = Calibration(slope: slope, intercept: intercept, scale: scale, milliseconds: mills)
                self.cals.insertOrUpdate(calibration)
            }
        }
        // makes sure things are sorted correctly by date. When delta's come in they might screw up the order.
        self.sgvs.sortByDate()
        self.cals.sortByDate()
        self.mbgs.sortByDate()
        self.deviceStatus.sortByDate()
        
    }
}




