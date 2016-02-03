//
//  Complication.swift
//  Nightscouter
//
//  Created by Peter Ina on 2/2/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import SwiftyJSON

// Provide a private typealias for a platform specific color.
#if os(iOS) || os(watchOS)
    import UIKit

#elseif os(OSX)
    import Cocoa

#endif

public struct ComplicationModel: SiteCommonInfoDataSource, SiteCommonInfoDelegate, DirectionDisplayable, RawDataSource, RawDelegate, Dateable {
    
    public var milliseconds: Mills
    public var lastReadingDate: NSDate
    public var batteryLabel: String = ""
    public var rawHidden: Bool
    public var rawLabel: String
    public var nameLabel: String
    public var urlLabel: String = ""
    public var sgvLabel: String
    public var deltaLabel: String
    public var lookStale: Bool = false
    public var rawNoise: Noise

    public var lastReadingColor: Color = Color.clearColor()
    public var batteryColor: Color =  Color.clearColor()
    public var rawColor: Color
    public var sgvColor: Color
    public var deltaColor: Color
    
    public var units: Units
    public var direction: Direction
    
    public init(lastReadingDate: NSDate, rawHidden: Bool, rawLabel: String, nameLabel: String, sgvLabel: String, deltaLabel: String, rawColor: Color, sgvColor: Color, units: Units, direction: Direction, noise: Noise) {
        self.lastReadingDate = lastReadingDate

        self.rawHidden = rawHidden
        self.rawLabel = rawLabel
        self.nameLabel = nameLabel
        self.urlLabel = ""
        self.sgvLabel = sgvLabel
        self.deltaLabel = deltaLabel
        self.lookStale = false
        self.rawColor = rawColor
        self.deltaColor = sgvColor
        self.sgvColor = sgvColor
        
        self.milliseconds = lastReadingDate.timeIntervalSince1970.millisecond
        self.units = units
        self.direction = direction
        self.rawNoise = noise
    }

}


extension ComplicationModel: Encodable {
    struct JSONKey {
        static let lastReadingDate = "lastReadingDate"
        static let rawHidden = "rawHidden"
        static let rawLabel = "rawLabel"
        static let nameLabel = "nameLabel"
        static let sgvLabel = "sgvLabel"
        static let deltaLabel = "deltaLabel"
        static let rawColor = "rawColor"
        static let sgvColor = "sgvColor"
        static let units = "units"
        static let noise = "noise"
        static let direction = "direction"

    }
    
    func encode() -> [String : AnyObject] {
        return [
            JSONKey.lastReadingDate: lastReadingDate,
            JSONKey.rawHidden: rawHidden,
            JSONKey.rawLabel: rawLabel,
            JSONKey.nameLabel: nameLabel,
            JSONKey.sgvLabel: sgvLabel,
            JSONKey.deltaLabel: deltaLabel,
            JSONKey.rawColor: rawColor.toHexString(),
            JSONKey.sgvColor: sgvColor.toHexString(),
            JSONKey.units: units.rawValue,
            JSONKey.direction: direction.rawValue,
            JSONKey.noise: rawNoise.rawValue
        ]
        
    }
}

extension ComplicationModel: Decodable {
    static func decode(dict: [String : AnyObject]) -> ComplicationModel? {
        
        let json = JSON(dict)

        return ComplicationModel(
            lastReadingDate: dict[JSONKey.lastReadingDate] as! NSDate,
          
            rawHidden: json[JSONKey.rawHidden].boolValue,
            rawLabel: json[JSONKey.rawLabel].stringValue,
            nameLabel: json[JSONKey.nameLabel].stringValue,
            sgvLabel: json[JSONKey.sgvLabel].stringValue,
            deltaLabel: json[JSONKey.deltaLabel].stringValue,
            rawColor: Color(hexString: json[JSONKey.rawColor].stringValue),
            sgvColor: Color(hexString: json[JSONKey.sgvColor].stringValue),
                units: Units(rawValue: json[JSONKey.units].stringValue) ?? .Mgdl,
            direction:  Direction(rawValue: json[JSONKey.direction].stringValue) ?? .None,
            noise:  Noise(rawValue: json[JSONKey.noise].intValue) ?? .Unknown
        )
    }
}