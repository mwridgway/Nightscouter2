//
//  ComplicationDataSourceGenerator.swift
//  Nightscouter
//
//  Created by Peter Ina on 3/10/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation


public protocol ComplicationDataSourceGenerator {
    var primarySite: Site? { get }
    var oldestComplicationDataForPrimarySite: ComplicationTimelineEntry? { get }
    var latestComplicationDataForPrimarySite: ComplicationTimelineEntry? { get }
    var complicationUpdateInterval: NSTimeInterval { get }
    func generateComplicationDataForPrimarySite() -> [ComplicationTimelineEntry]
    func generateComplicationData(forSite site: Site) -> [ComplicationTimelineEntry]
    func generateComplicationData(forConfiguration configuration: ServerConfiguration, sgvs:[SensorGlucoseValue], calibrations:[Calibration]) -> [ComplicationTimelineEntry]
    
    func nearest(calibration cals: [Calibration], forDate date: NSDate) -> Calibration?
}

public extension ComplicationDataSourceGenerator {
    
    var complicationUpdateInterval: NSTimeInterval { return 60.0 * 30.0 }
    var nextRequestedComplicationUpdateDate: NSDate {
        guard let primarySite = primarySite else {
            return NSDate(timeIntervalSinceNow: complicationUpdateInterval)
        }
        
        return primarySite.date.dateByAddingTimeInterval(complicationUpdateInterval)
    }
    
    // MARK: Convenience methods for generating complication data.
    func generateComplicationDataForPrimarySite() -> [ComplicationTimelineEntry] {
        guard let site = primarySite, configuration = site.configuration else {
            return []
        }
        return generateComplicationData(forConfiguration: configuration, sgvs: site.sgvs, calibrations: site.cals)
    }
    
    func generateComplicationData(forSite site: Site) -> [ComplicationTimelineEntry] {
        return generateComplicationData(forConfiguration: site.configuration ?? ServerConfiguration(), sgvs: site.sgvs, calibrations: site.cals)
    }
    
    func nearest(calibration cals: [Calibration], forDate date: NSDate) -> Calibration? {
        var desiredIndex: Int?
        var minDate: NSTimeInterval = fabs(NSDate().timeIntervalSinceNow)
        for (index, cal) in cals.enumerate() {
            let dateInterval = fabs(cal.date.timeIntervalSinceDate(date))
            let compared = minDate < dateInterval
            if compared {
                minDate = dateInterval
                desiredIndex = index
            }
        }
        guard let index = desiredIndex else {
            print("NON-FATAL ERROR: No valid index was found... return first calibration if its there.")
            return cals.first
        }
        return cals[safe: index]
    }
}
