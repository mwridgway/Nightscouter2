//
//  ServerConfiguration.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public struct ServerConfiguration: CustomStringConvertible {
    public let status: String
    public let version: String
    public let name: String
    public let serverTime: String
    public let apiEnabled: Bool
    public let careportalEnabled: Bool
    public let boluscalcEnabled: Bool
    public let head:String
    public let settings: Settings?
    
    public var description: String {
        var dict = [String: AnyObject]()
        
        dict["status"] = status
        dict["apiEnabled"] = apiEnabled
        dict["serverTime"] = serverTime
        dict["careportalEnabled"] = careportalEnabled
        dict["boluscalcEnabled"] = boluscalcEnabled
        dict["settings"] = settings?.description
        dict["head"] = head
        dict["version"] = version
        dict["name"] = name
        
        return dict.description
    }
    
    public init() {
        self.status = "okToTest"
        self.version = "0.0.0test"
        self.name = "NightscoutTest"
        self.serverTime = "2016-01-13T15:04:59.059Z"
        self.apiEnabled = true
        self.careportalEnabled = true
        self.boluscalcEnabled = true
        
        let placeholderAlarm1 = [15, 30, 45, 60]
        let placeholderAlarm2 = [30, 60, 90, 120]

        
        let alrm = Alarm(urgentHigh: true, urgentHighMins: placeholderAlarm2, high: true, highMins: placeholderAlarm2, low: true, lowMins: placeholderAlarm1, urgentLow: true, urgentLowMins: placeholderAlarm1, warnMins: placeholderAlarm2)
        let timeAgo = TimeAgoAlert(warn: true, warnMins: 10, urgent: true, urgentMins: 15)
        let plugins: [ShowPlugins] = [ShowPlugins.delta, ShowPlugins.rawbg]
        let thre = Thresholds(bgHigh: 300, bgLow: 70, bgTargetBottom: 60, bgTargetTop: 250)
        let atype = AlarmType.predict
        self.settings = Settings(units: .Mgdl, timeFormat: 12, nightMode: false, editMode: false, showRawbg: RawBGMode.Always, customTitle: "NightscoutDefault", theme: "color", alarms: alrm, timeAgo: timeAgo, scaleY: "log", language: "en", showPlugins: plugins, enable: plugins, thresholds: thre, baseURL: "", alarmType: atype, heartbeat: 60)

        self.head = "EMPTY"
    }
    
    public init(status: String, version: String, name: String, serverTime: String, api: Bool, carePortal: Bool, boluscalc: Bool, settings: Settings?, head: String) {
        self.status = "okToTest"
        self.version = "0.0.0test"
        self.name = "NightscoutDefault"
        self.serverTime = AppConfiguration.serverTimeDateFormatter.stringFromDate(NSDate())
        self.apiEnabled = true
        self.careportalEnabled = true
        self.boluscalcEnabled = true
        self.settings = settings
        self.head = "ZZZZ"
    }
    
}

extension ServerConfiguration {
    public var displayName: String {
        if let settings = settings {
            return settings.customTitle
        } else {
            return name
        }
    }
    
    public var displayRawData: Bool {
        if let settings = settings {
            let rawEnabled = settings.enable.contains(ShowPlugins.rawbg)
            if rawEnabled {
                switch settings.showRawbg {
                case .Noise:
                    return true
                case .Always:
                    return true
                case .Never:
                    return false
                }
                
            }
        }
        return false
        
    }
    
    public var displayUnits: Units {
        if let settings = settings {
            return settings.units
        }
        return .Mgdl
    }
}

public struct Settings: CustomStringConvertible {
    public let units: Units
    public let timeFormat: Int
    public let nightMode: Bool
    public let editMode: Bool
    public let showRawbg: RawBGMode
    public let customTitle: String
    public let theme: String
    public let alarms: Alarm
    public let timeAgo: TimeAgoAlert
    public let scaleY: String
    public let language: String
    public let showPlugins: [ShowPlugins]
    public let enable: [ShowPlugins]
    public let thresholds: Thresholds
    public let baseURL: String
    public let alarmType: AlarmType
    public let heartbeat: Int
    
    public var description: String {
        let dict = ["units": units.description, "timeFormat": timeFormat, "nightMode": nightMode.description, "showRawbg": showRawbg.rawValue, "customTitle": customTitle, "theme": theme, "alarms": alarms.description, "language": language, "baseURL": baseURL]
        return dict.description
    }
}

public enum ShowPlugins: String, CustomStringConvertible {
    case careportal = "careportal"
    case rawbg = "rawbg"
    case iob = "iob"
    case ar2 = "ar2"
    case treatmentnotify = "treatmentnotify"
    case delta = "delta"
    case direction = "direction"
    case upbat = "upbat"
    case errorcodes = "errorcodes"
    case simplealarms = "simplealarms"
    case pushover = "pushover"
    case maker = "maker"
    case cob = "cob"
    case bwp = "bwp"
    case cage = "cage"
    case basal = "basal"
    case profile = "profile"
    case timeago = "timeago"
    
    public var description: String {
        return self.rawValue
    }
}

public enum Units: String, CustomStringConvertible {
    case Mgdl = "mg/dL"
    case Mmol = "mmol"
    
    public init() {
        self = .Mgdl
    }
    
    public var description: String {
        switch self {
        case .Mgdl:
            return "mg/dL"
        case .Mmol:
            return "mmol/L"
        }
    }
    
    public var descriptionShort: String {
        switch self {
        case .Mgdl:
            return "mg"
        case .Mmol:
            return "mmol"
        }
    }
}

public enum RawBGMode: String, CustomStringConvertible {
    case Never = "never"
    case Always = "always"
    case Noise = "noise"
    
    public var description: String {
        return self.rawValue
    }
}

public struct Thresholds: CustomStringConvertible {
    public let bgHigh: Double
    public let bgLow: Double
    public let bgTargetBottom :Double
    public let bgTargetTop :Double
    
    public var description: String {
        let dict = ["bgHigh": bgHigh, "bgLow": bgLow, "bgTargetBottom": bgTargetBottom, "bgTargetTop": bgTargetTop]
        return dict.description
    }
}

extension Thresholds: ColorBoundable {
    public var bottom: Double { return self.bgLow }
    public var targetBottom: Double { return self.bgTargetBottom }
    public var targetTop: Double { return self.bgTargetTop }
    public var top: Double { return self.bgHigh }
}

public struct Alarm: CustomStringConvertible {
    public let urgentHigh: Bool
    public let urgentHighMins: [Int]
    public let high: Bool
    public let highMins: [Int]
    public let low: Bool
    public let lowMins: [Int]
    public let urgentLow: Bool
    public let urgentLowMins: [Int]
    public let warnMins: [Int]
    
    public var description: String {
        let dict = ["urgentHigh": urgentHigh, "urgentHighMins": urgentHighMins, "high": high, "highMins": highMins, "low": low, "lowMins": lowMins, "urgentLow": urgentLow, "urgentLowMins": urgentLowMins, "warnMins": warnMins]
        return dict.description
    }
}



public enum AlarmType: String, CustomStringConvertible {
    case predict = "predict"
    case simple = "simple"
    
    public var description: String {
        return self.rawValue
    }
}

public struct TimeAgoAlert: CustomStringConvertible {
    public let warn: Bool
    public let warnMins: NSTimeInterval
    public let urgent: Bool
    public let urgentMins: NSTimeInterval
    
    public var description: String {
        let dict = ["warn": warn, "warnMins": warnMins, "urgent": urgent, "urgentMins": urgentMins]
        return dict.description
    }
}

public extension TimeAgoAlert {
    public func isDataStaleWith(interval sinceNow: NSTimeInterval) -> (warn: Bool, urgent: Bool) {
        return isDataStaleWith(interval: sinceNow, warn: self.warnMins, urgent: self.urgentMins)
    }
    
    private func isDataStaleWith(interval sinceNow: NSTimeInterval, warn: NSTimeInterval, urgent: NSTimeInterval, fallback: NSTimeInterval = NSTimeInterval(600)) -> (warn: Bool, urgent: Bool) {
        
        let warnValue: NSTimeInterval = -max(fallback, warn)
        let urgentValue: NSTimeInterval = -max(fallback, urgent)
        let returnValue = (sinceNow < warnValue, sinceNow < urgentValue)
        
        #if DEBUG
            // print("\(__FUNCTION__): {sinceNow: \(sinceNow), warneValue: \(warnValue), urgentValue: \(urgentValue), fallback:\(-fallback), returning: \(returnValue)}")
        #endif
        
        return returnValue
    }
    
}
