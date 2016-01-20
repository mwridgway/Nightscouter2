//
//  File.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/14/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//
import Foundation
import UIKit

public protocol SiteCommonInfoDataSource {
    //var lastReadingLabel: String { get }
    var lastReadingDate: NSDate { get }
    var batteryLabel: String { get }
    var rawHidden: Bool { get }
    var rawLabel: String { get }
    var nameLabel: String { get }
    var urlLabel: String { get }
    var sgvLabel: String { get }
    var deltaLabel: String { get }
    var lookStale: Bool { get }
}

public protocol SiteCommonInfoDelegate {
    var lastReadingColor: UIColor { get }
    var batteryColor: UIColor { get }
    var rawColor: UIColor { get }
    var sgvColor: UIColor { get }
    var deltaColor: UIColor { get }
}

public protocol DirectionDisplayable {
    var direction: Direction { get }
}

public protocol CompassViewDataSource: SiteCommonInfoDataSource, DirectionDisplayable {
    var text: String { get }
    var detailText: String { get }
}

public protocol CompassViewDelegate: SiteCommonInfoDelegate {
    var desiredColor: DesiredColorState { get }
}

public typealias TableViewRowWithCompassDataSource = protocol<SiteCommonInfoDataSource, CompassViewDataSource>
public typealias TableViewRowWithCompassDelegate = protocol<SiteCommonInfoDelegate, CompassViewDelegate>
public typealias TableViewRowWithOutCompassDataSource = protocol<SiteCommonInfoDataSource, DirectionDisplayable>
public typealias TableViewRowWithOutCompassDelegate = protocol<SiteCommonInfoDelegate>

public struct SiteSummaryModelViewModel: SiteCommonInfoDataSource, DirectionDisplayable, SiteCommonInfoDelegate, CompassViewDataSource, CompassViewDelegate {

    public var lastReadingDate: NSDate
    public var batteryLabel: String
    public var rawHidden: Bool
    public var rawLabel: String
    public var nameLabel: String
    public var urlLabel: String
    public var sgvLabel: String
    public var deltaLabel: String
    
    public var lastReadingColor: UIColor
    public var batteryColor: UIColor
    public var rawColor: UIColor
    public var sgvColor: UIColor
    public var deltaColor: UIColor
    
    public var direction: Direction
    public var text: String
    public var detailText: String
    public var lookStale: Bool
    public var desiredColor: DesiredColorState
    
    public init(withSite site:Site) {
        
        let displayUrlString = site.url.host ?? site.url.absoluteString
        
        guard let configuration = site.configuration, settings = configuration.settings else {
            
            // Last Reading
            self.lastReadingDate = NSDate(timeIntervalSince1970: AppConfiguration.Constant.knownMilliseconds/1000)
            self.lastReadingColor = PlaceHolderStrings.defaultColor.colorValue
            
            // Raw
            self.rawLabel = PlaceHolderStrings.raw
            self.rawColor = PlaceHolderStrings.defaultColor.colorValue
            self.rawHidden = false
            
            // Sgv
            self.sgvLabel = PlaceHolderStrings.sgv
            self.sgvColor = PlaceHolderStrings.defaultColor.colorValue
            
            // Battery
            self.batteryLabel = PlaceHolderStrings.battery
            self.batteryColor = PlaceHolderStrings.defaultColor.colorValue
            
            // Name and URL
            self.nameLabel = PlaceHolderStrings.displayName
            self.urlLabel = displayUrlString
            
            // Delta
            self.deltaLabel = PlaceHolderStrings.delta
            self.deltaColor = PlaceHolderStrings.defaultColor.colorValue
            
            // Compass
            self.detailText = self.deltaLabel
            self.desiredColor = PlaceHolderStrings.defaultColor
            self.lookStale = false
            self.direction = Direction.None
            self.text = self.sgvLabel
            
            return
        }
        
        let units: Units = configuration.displayUnits
        let displayName: String = configuration.displayName
        let isRawDataAvailable = configuration.displayRawData
        
        var deltaString: String?
        var lastReadingDate: NSDate?
        var sgvString: String?
        var rawString: String?
        var batteryString: String?
        var direction: Direction?
        
        var lastReadingColorVar: DesiredColorState?
        var rawColorVar: DesiredColorState?
        var sgvColorVar: DesiredColorState?
        var batteryColorVar: DesiredColorState?
        
        var isStaleData: (warn: Bool, urgent: Bool) = (false, false)
        
        if let latestSgv = site.sgvs.first {
            let thresholds: Thresholds = settings.thresholds
            sgvColorVar = thresholds.desiredColorState(forValue: latestSgv.mgdl)
            
            lastReadingDate = latestSgv.date
            
            sgvString = "\(latestSgv.mgdl.formattedForMgdl)"
            if units == .Mmol {
                sgvString = latestSgv.mgdl.formattedForMmol
            }
            
            direction = latestSgv.direction
            
            if let previousSgv = site.sgvs[safe:1] where latestSgv.isSGVOk {
                let delta = latestSgv.mgdl - previousSgv.mgdl
                deltaString = "\(delta.formattedForBGDelta) \(units.description)"
            }
            
            if let latestCalibration = site.cals.first {
                let raw = calculateRawBG(fromSensorGlucoseValue: latestSgv, calibration: latestCalibration)
                rawColorVar = thresholds.desiredColorState(forValue: raw)
                
                var rawFormattedString = "\(raw.formattedForMgdl)"
                if configuration.displayUnits == .Mmol {
                    rawFormattedString = raw.formattedForMmol
                }
                
                rawString =  "\(rawFormattedString) : \(latestSgv.noise.description)"
            }
            
            if let deviceStatus = site.deviceStatus.first {
                batteryString = deviceStatus.batteryLevel
                batteryColorVar = deviceStatus.desiredColorState
            }
            
            // Calculate if the lastest watch entry we got from the server is stale.
            let timeAgo = latestSgv.date.timeIntervalSinceNow
            isStaleData = settings.timeAgo.isDataStaleWith(interval: timeAgo)
            
            if isStaleData.warn {
                batteryString = PlaceHolderStrings.battery
                batteryColorVar = DesiredColorState.Neutral
                
                rawString = PlaceHolderStrings.raw
                rawColorVar = DesiredColorState.Neutral
                
                deltaString = PlaceHolderStrings.delta
                
                sgvString = PlaceHolderStrings.sgv
                sgvColorVar = DesiredColorState.Neutral
                lastReadingColorVar = DesiredColorState.Warning
            }
            
            if isStaleData.urgent{
                lastReadingColorVar = DesiredColorState.Alert
            }
            
        }
        
        self.lastReadingDate = lastReadingDate ?? NSDate(timeIntervalSince1970: AppConfiguration.Constant.knownMilliseconds)
        self.lastReadingColor = lastReadingColorVar?.colorValue ?? PlaceHolderStrings.defaultColor.colorValue
        
        self.rawLabel = rawString ?? PlaceHolderStrings.raw
        self.rawColor = rawColorVar?.colorValue ?? PlaceHolderStrings.defaultColor.colorValue
        self.rawHidden = !isRawDataAvailable
        
        self.sgvLabel = sgvString ?? PlaceHolderStrings.sgv
        self.sgvColor = sgvColorVar?.colorValue ?? PlaceHolderStrings.defaultColor.colorValue
        
        self.batteryLabel = batteryString ?? PlaceHolderStrings.battery
        self.batteryColor = batteryColorVar?.colorValue ?? PlaceHolderStrings.defaultColor.colorValue
        
        self.nameLabel = displayName ?? PlaceHolderStrings.displayName
        self.urlLabel = displayUrlString ?? PlaceHolderStrings.urlName
        
        self.deltaLabel = deltaString ?? PlaceHolderStrings.delta
        self.deltaColor = sgvColorVar?.colorValue ?? PlaceHolderStrings.defaultColor.colorValue
        
        
        self.detailText = self.deltaLabel
        self.desiredColor = sgvColorVar ?? PlaceHolderStrings.defaultColor
        self.lookStale = isStaleData.warn
        self.direction = direction ?? Direction.None
        self.text = self.sgvLabel
        
    }
}

