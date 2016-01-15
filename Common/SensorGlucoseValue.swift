//
//  SensorGlucoseValue.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public struct SensorGlucoseValue: CustomStringConvertible, Dateable, GlucoseValueHolder, DeviceOwnable {
    public let device: Device, direction: Direction
    public let rssi: Int, unfiltered: Double, filtered: Double, mgdl: mgdlValue
    public let noise: Noise
    public let milliseconds: Double
    
    public var description: String {
        return "{ SensorGlucoseValue: { device: \(device), mgdl: \(mgdl), date: \(date), direction: \(direction) } }"
    }
    
    public init() {
        device = Device.TestDevice
        direction = Direction.NotComputable
        rssi = 188
        unfiltered = 186624
        filtered = 180800
        mgdl = AppConfiguration.Constant.knownMgdl
        noise = Noise.Clean
        milliseconds = AppConfiguration.Constant.knownMilliseconds
    }
    
    public init(direction: Direction, device: Device, rssi: Int, unfiltered: Double, filtered: Double, mgdl: mgdlValue, noise: Noise, milliseconds: Double) {
        self.direction = direction
        self.filtered = filtered
        self.unfiltered = unfiltered
        self.rssi = rssi
        self.milliseconds = milliseconds
        self.mgdl = mgdl
        self.device = device
        self.noise = noise
    }
}

public enum ReservedValues: mgdlValue, CustomStringConvertible {
    case NoGlucose=0, SensoreNotActive=1, MinimalDeviation=2, NoAntenna=3, SensorNotCalibrated=5, CountsDeviation=6, AbsoluteDeviation=9, PowerDeviation=10, BadRF=12, HupHolland=17, Low=30
    
    public var description: String {
        switch (self) {
        case .NoGlucose:
            return "?NC"
        case .SensoreNotActive:
            return "?NA"
        case .MinimalDeviation:
            return "?MD"
        case .NoAntenna:
            return "?NA"
        case .SensorNotCalibrated:
            return "?NC"
        case .CountsDeviation:
            return "?CD"
        case .AbsoluteDeviation:
            return "?AD"
        case .PowerDeviation:
            return "?PD"
        case .BadRF:
            return "?RF✖"
        case .HupHolland:
            return "MH"
        case .Low:
            return LocalizedString.sgvLowString.localized
        }
    }
}

extension ReservedValues {
    init?(mgdl: mgdlValue) {
        if mgdl >= 30 && mgdl < 40 {
            self.init(rawValue: 30)
        } else {
            
            self.init(rawValue: mgdl)
        }
    }
}
public extension GlucoseValueHolder {
    
}



public enum Direction : String, CustomStringConvertible {
    case None = "None", DoubleUp = "DoubleUp", SingleUp = "SingleUp", FortyFiveUp = "FortyFiveUp", Flat = "Flat", FortyFiveDown = "FortyFiveDown", SingleDown = "SingleDown", DoubleDown = "DoubleDown", NotComputable = "NOT COMPUTABLE", RateOutOfRange = "RateOutOfRange", Not_Computable = "NOT_COMPUTABLE"
    
    public var description : String {
        switch(self) {
        case .None: return NSLocalizedString("directionNone", tableName: nil, bundle:  NSBundle.mainBundle(), value: "None", comment: "Label used to indicate a direction.")
        case .DoubleUp: return NSLocalizedString("directionDoubleUp", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Double Up", comment: "Label used to indicate a direction.")
        case .SingleUp: return NSLocalizedString("directionSingleUp", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Single Up", comment: "Label used to indicate a direction.")
        case .FortyFiveUp: return NSLocalizedString("directionFortyFiveUp", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Forty Five Up", comment: "Label used to indicate a direction.")
        case .Flat: return NSLocalizedString("directionFlat", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Flat", comment: "Label used to indicate a direction.")
        case .FortyFiveDown: return NSLocalizedString("directionFortyFiveDown", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Forty Five Down", comment: "Label used to indicate a direction.")
        case .SingleDown: return NSLocalizedString("directionSingleDown", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Single Down", comment: "Label used to indicate a direction.")
        case .DoubleDown: return NSLocalizedString("directionDoubleDown", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Double Down", comment: "Label used to indicate a direction.")
        case .NotComputable, .Not_Computable: return NSLocalizedString("directionNotComputable", tableName: nil, bundle:  NSBundle.mainBundle(), value: "N/C", comment: "Label used to indicate a direction.")
        case .RateOutOfRange: return NSLocalizedString("directionRateOutOfRange", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Rate Out Of Range", comment: "Label used to indicate a direction.")
            
        }
    }
    
    public var emojiForDirection: String {
        get {
            switch (self) {
            case .None: return ""
            case .DoubleUp: return  "⇈"
            case .SingleUp: return "↑"
            case .FortyFiveUp: return  "➚"
            case .Flat: return "→"
            case .FortyFiveDown: return "➘"
            case .SingleDown: return "↓"
            case .DoubleDown: return  "⇊"
            case .NotComputable, .Not_Computable: return "-"
            case .RateOutOfRange: return "✕"
            }
        }
    }
    
    static public func directionForString(directionString: String) -> Direction {
        switch directionString {
        case "None": return .None
        case "DoubleUp": return .DoubleUp
        case "SingleUp": return .SingleUp
        case "FortyFiveUp": return .FortyFiveUp
        case "Flat": return .Flat
        case "FortyFiveDown": return .FortyFiveDown
        case "SingleDown": return .SingleDown
        case "DoubleDown": return .DoubleDown
        case "NOT COMPUTABLE", "NOT_COMPUTABLE": return .NotComputable
        case "RateOutOfRange": return .RateOutOfRange
        default: return .None
        }
    }
    
    public init() {
        self = .None
    }
}

public enum Noise : Int, CustomStringConvertible {
    case None = 0, Clean = 1, Light = 2, Medium = 3, Heavy = 4, Unknown = 5
    
    public var description: String {
        switch (self) {
        case .None: return NSLocalizedString("noiseNone", tableName: nil, bundle:  NSBundle.mainBundle(), value: "None", comment: "Label used to indicate a direction.")
        case .Clean: return NSLocalizedString("noiseClean", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Clean", comment: "Label used to indicate a direction.")
        case .Light: return NSLocalizedString("noiseLight", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Light", comment: "Label used to indicate a direction.")
        case .Medium: return NSLocalizedString("noiseMedium", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Medium", comment: "Label used to indicate a direction.")
        case .Heavy: return NSLocalizedString("noiseHeavy", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Heavy", comment: "Label used to indicate a direction.")
        case .Unknown: return NSLocalizedString("noiseUnkown", tableName: nil, bundle:  NSBundle.mainBundle(), value: "Unknown", comment: "Label used to indicate a direction.")
        }
    }
    
    public init() {
        self = .None
    }
}