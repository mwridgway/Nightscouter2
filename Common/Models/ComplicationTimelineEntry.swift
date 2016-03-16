//
//  Complication.swift
//  Nightscouter
//
//  Created by Peter Ina on 2/2/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public struct ComplicationTimelineEntry: SiteCommonInfoDataSource, SiteCommonInfoDelegate, DirectionDisplayable, RawDataSource, Dateable {
    
    public var milliseconds: Mills
    public var lastReadingDate: NSDate
    public var rawLabel: String
    
    public var rawHidden: Bool {
        return (rawLabel == "")
    }
    public var nameLabel: String

    public var urlLabel: String = ""
    public var sgvLabel: String
    public var deltaLabel: String
    public var rawNoise: Noise
    
    public var deltaShort: String {
       return deltaLabel.stringByReplacingOccurrencesOfString(units.description, withString: PlaceHolderStrings.deltaAltJ)
    }
 
    public var lastReadingColor: Color = Color.clearColor()

    public var sgvColor: Color
    public var deltaColor: Color
    
    public var units: Units
    public var direction: Direction
    
    public var stale: Bool {
        return date.timeIntervalSinceNow < -(60.0 * 15.0)
    }
    
    public init(date: NSDate, rawLabel: String?, nameLabel: String, sgvLabel: String, deltaLabel: String = "", tintColor: Color, units: Units = .Mgdl, direction: Direction = .None, noise: Noise = .None) {
        self.lastReadingDate = date

        self.rawLabel = rawLabel ?? ""
        self.nameLabel = nameLabel
        self.urlLabel = ""
        self.sgvLabel = sgvLabel
        self.deltaLabel = deltaLabel
        self.deltaColor = tintColor
        self.sgvColor = tintColor
        
        self.milliseconds = date.timeIntervalSince1970.millisecond
        self.units = units
        self.direction = direction
        self.rawNoise = noise
    }

}
