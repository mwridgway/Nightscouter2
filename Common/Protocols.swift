//
//  Protocols.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

#if os(iOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
//import Foundation

// MARK: - Dateable. Store values in milliseconds, get a date back.
public protocol Dateable {
    var milliseconds: Double { get }
}
public extension Dateable {
    public var date: NSDate {
        return NSDate(timeIntervalSince1970: (NSTimeInterval(milliseconds) / 1000))
    }
}

// Common fields for holding a glucose value.
public typealias mgdlValue = Double
public protocol GlucoseValueHolder {
    var mgdl: mgdlValue { get }
    var isSGVOk: Bool { get }
}

public extension GlucoseValueHolder {
    public var reservedValueUpperEnd: mgdlValue { return 17 }
    
    public var isSGVOk: Bool {
        return mgdl >= reservedValueUpperEnd
    }
}

public protocol ColorBoundable {
    var bottom: Double { get }
    var targetBottom: Double { get }
    var targetTop: Double { get }
    var top: Double { get }
    
    func desiredColorState(forValue value: Double) -> DesiredColorState
}

extension ColorBoundable {
    public func desiredColorState(forValue value: Double) -> DesiredColorState {
        
        var desiredState: DesiredColorState?
        if (value >= top) {
            desiredState = .Alert
        } else if (value > targetTop && value < top) {
            desiredState =  .Warning
        } else if (value >= targetBottom && value <= targetTop) {
            desiredState = .Positive
        } else if (value < targetBottom && value > bottom) {
            desiredState = .Warning
        } else if (value <= bottom && value != 0) {
            desiredState = .Alert
        }
        
        return desiredState ?? .Neutral
    }
}

// TODO: Should this be here?
public enum DesiredColorState: String, CustomStringConvertible {
    case Alert, Warning, Positive, Neutral
    
    public var description: String {
        return self.rawValue
    }
}

// Records tagged with a device share this field.
public protocol DeviceOwnable {
    var device: Device { get }
}

public enum Device: String, CustomStringConvertible {
    case Unknown = "unknown", Dexcom = "dexcom", xDripDexcomShare = "xDrip-DexcomShare", WatchFace = "watchFace", Share2 = "share2", TestDevice = "testDevice"
    
    public var description: String {
        return self.rawValue
    }
    
    public init() {
        self = .Unknown
    }
}

// TODO: Create Struct to hold wacth or now data like delta, current bg, raw and battery....
public protocol DeltaDisplayable {
    var delta: Int { get }
    var deltaNumberFormatter: NSNumberFormatter { get }
}

extension DeltaDisplayable {
    var deltaNumberFormatter: NSNumberFormatter {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.positivePrefix = formatter.plusSign
        formatter.negativePrefix = formatter.minusSign
        
        return formatter
    }
}

//public protocol RawCalculable{
//    func calculateRawBG(fromSensorGlucoseValue sgv: SensorGlucoseValue, calibration cal: Calibration) -> mgdlValue
//}

//extension RawCalculable {

public func calculateRawBG(fromSensorGlucoseValue sgv: SensorGlucoseValue, calibration cal: Calibration) -> mgdlValue {
    var raw: Double = 0
    
    let unfiltered = sgv.unfiltered
    let filtered = sgv.filtered
    let sgv: Double = sgv.mgdl
    
    let slope = cal.slope
    let scale = cal.scale
    let intercept = cal.intercept
    
    if (slope == 0 || unfiltered == 0 || scale == 0) {
        raw = 0
    } else if (filtered == 0 || sgv < 40) {
        raw = scale * (unfiltered - intercept) / slope
    } else {
        let ratioCalc = scale * (filtered - intercept) / slope
        let ratio = ratioCalc / sgv
        
        let rawCalc = scale * (unfiltered - intercept) / slope
        raw = rawCalc / ratio
    }
    
    return round(raw)
}
//}

// Provide a private typealias for a platform specific color.
#if os(iOS) || os(watchOS)
    private typealias AppColor = UIColor
#elseif os(OSX)
    private typealias AppColor = NSColor
#endif
public extension DesiredColorState {

    private static let colorMapping = [
        DesiredColorState.Neutral: AppColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1.000),
        DesiredColorState.Alert: AppColor(red: 1.000, green: 0.067, blue: 0.310, alpha: 1.000),
        DesiredColorState.Positive: AppColor(red: 0.016, green: 0.871, blue: 0.443, alpha: 1.000),
        DesiredColorState.Warning: AppColor(red: 1.000, green: 0.902, blue: 0.125, alpha: 1.000)
    ]
    
    #if os(iOS) || os(watchOS)
    public var colorValue: UIColor {
        return DesiredColorState.colorMapping[self]!
    }
    
    #elseif os(OSX)
    public var colorValue: NSColor {
    return DesiredColorState.colorMapping[self]!
    }

    #endif
}
/*
public func colorForDesiredColorState(state:DesiredColorState) -> UIColor {
    switch (state) {
    case .Neutral:
    return UIColor.grayColor()//NSAssetKit.predefinedNeutralColor
    case .Alert:
    return UIColor.redColor()//NSAssetKit.predefinedAlertColor
    case .Positive:
    return UIColor.greenColor()//NSAssetKit.predefinedPostiveColor
    case .Warning:
    return UIColor.orangeColor()//NSAssetKit.predefinedWarningColor
    }
}
*/