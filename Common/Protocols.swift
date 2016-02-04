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

public typealias Mills = Double

// MARK: - Dateable. Store values in milliseconds, get a date back.
public protocol Dateable {
    var milliseconds: Mills { get }
}

public extension Dateable {
    public var date: NSDate {
        return NSDate(timeIntervalSince1970: (NSTimeInterval(milliseconds) / 1000))
    }
}
public func == <T: Dateable>(lhs: T, rhs: T) -> Bool {
    return lhs.date == rhs.date
}

extension DeviceStatus: Equatable { }
extension MeteredGlucoseValue: Equatable { }
extension Calibration: Equatable { }
extension SensorGlucoseValue: Equatable { }


// Common fields for holding a glucose value.
public typealias MgdlValue = Double
public protocol GlucoseValueHolder {
    var mgdl: MgdlValue { get }
    var isSGVOk: Bool { get }
}

public extension GlucoseValueHolder {
    public var reservedValueUpperEnd: MgdlValue { return 17 }
    
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
    case Alert, Warning, Positive, Neutral, Default
    
    public var description: String {
        return self.rawValue
    }
}

// Records tagged with a device share this field.
public protocol DeviceOwnable {
    var device: Device { get }
}

public enum Device: String, CustomStringConvertible {
    case Unknown, Dexcom = "dexcom", xDripDexcomShare = "xDrip-DexcomShare", WatchFace = "watchFace", Share2 = "share2", TestDevice = "testDevice", Paradigm = "connect://paradigm"
    
    public var description: String {
        return self.rawValue
    }
    
    public init() {
        self = .Unknown
    }
}

// TODO: Create Struct to hold wacth or now data like delta, current bg, raw and battery....
public protocol DeltaDisplayable {
    var delta: MgdlValue { get set }
    var deltaNumberFormatter: NSNumberFormatter { get }
    func deltaString(forUnits units: Units) -> String
}

extension DeltaDisplayable {
    public var deltaNumberFormatter: NSNumberFormatter {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.positivePrefix = formatter.plusSign
        formatter.negativePrefix = formatter.minusSign
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.secondaryGroupingSize = 1
        
        return formatter
    }
    
    public func deltaString(forUnits units: Units) -> String {
        var rawDelta: MgdlValue = 0
        switch units {
        case .Mgdl:
            rawDelta = delta
        case .Mmol:
            rawDelta = delta.toMmol
        }
        return deltaNumberFormatter.stringFromNumber(rawDelta) ?? PlaceHolderStrings.delta
    }
}

public func calculateRawBG(fromSensorGlucoseValue sgv: SensorGlucoseValue, calibration cal: Calibration) -> MgdlValue {
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
        DesiredColorState.Warning: AppColor(red: 1.000, green: 0.902, blue: 0.125, alpha: 1.000),
        DesiredColorState.Default: AppColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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

// Iterates srtuct properties
func iterateEnum<T: Hashable>(_: T.Type) -> AnyGenerator<T> {
    var i = 0
    return anyGenerator {
        let next = withUnsafePointer(&i) { UnsafePointer<T>($0).memory }
        return next.hashValue == i++ ? next : nil
    }
}
