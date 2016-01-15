//
//  DeviceStatus.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

/// A record type provided by the Nightscout API, contains regarding the battery level of the uploading device.
public struct DeviceStatus: CustomStringConvertible, Dateable {
    private let zeroSymbolForBattery: String = PlaceHolderStrings.battery
    
    /** 
     The battery's raw value provided by the Nightscout API.
     The properly converted string can be found in:
     
     var batteryLevel: String { get }
     
     */
    public let uploaderBattery: Int
    public var milliseconds: Double
    public var batteryLevel: String {
        get {
            let numFormatter = NSNumberFormatter()
            
            numFormatter.locale = NSLocale.systemLocale()
            numFormatter.numberStyle = .PercentStyle
            numFormatter.zeroSymbol = zeroSymbolForBattery
            
            let precentage = Float(uploaderBattery)/100
            
            return numFormatter.stringFromNumber(precentage ?? 0) ?? zeroSymbolForBattery
        }
    }
    
    
    /**
     
        Initializes a new device status structure with the default values.
     
        - Parameters:
            - None
     
     
        - Returns: DeviceStatus
     */
    public init() {
        uploaderBattery = 76
        milliseconds = AppConfiguration.Constant.knownMilliseconds
    }
    
    /**
        Initializes a new device status structure with the provided battery value and date in milliseconds.

        - Parameters:
            - uploaderBattery: The a whole integer value from JSON, like 0-99.
            - milliseconds: The EPOCH date converted into milliseconds.
        
        - Returns: DeviceStatus
     
     */
    public init(uploaderBattery: Int, milliseconds: Double) {
        self.uploaderBattery = uploaderBattery
        self.milliseconds = milliseconds
    }
    
    public var description: String {
        return "{ DeviceStatus: { uploaderBattery: \(uploaderBattery),  batteryLevel: \(batteryLevel) } }"
    }
}

extension DeviceStatus: ColorBoundable {
    public var bottom: Double { return 20.0 }
    public var targetBottom: Double { return 50.0 }
    public var targetTop: Double { return 100.0 }
    public var top: Double { return 101.0 }
    
    public var desiredColorState: DesiredColorState {
        return self.desiredColorState(forValue: Double(self.uploaderBattery))
    }
}
