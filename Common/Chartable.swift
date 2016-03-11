//
//  Chartable.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public protocol Chartable {
    var chartDictionary: [String: AnyObject] { get }
    var chartColor: String { get }
    var chartDateFormatter: NSDateFormatter { get }
    var jsonForChart: String { get }
}

extension Chartable {
    public var chartColor: String {
        return "white"
    }
    public var chartDateFormatter: NSDateFormatter {
        let nsDateFormatter = NSDateFormatter()
        nsDateFormatter.dateFormat = "EEE MMM d HH:mm:ss zzz yyy"
        nsDateFormatter.timeZone = NSTimeZone.localTimeZone()

        return nsDateFormatter
    }
    
    public var jsonForChart: String {
        let jsObj =  try? NSJSONSerialization.dataWithJSONObject(self.chartDictionary, options:[])
        let str = NSString(data: jsObj!, encoding: NSUTF8StringEncoding)
        return String(str!)
    }
}

extension SensorGlucoseValue: Chartable {
    public var chartDictionary: [String: AnyObject] {
        get{
            let entry: SensorGlucoseValue = self
            let dateForJson = chartDateFormatter.stringFromDate(entry.date)
            let dict: [String: AnyObject] = ["color" : chartColor, "date" : dateForJson, "filtered" : entry.filtered, "noise": entry.noise.rawValue, "sgv" : entry.mgdl, "type" : "sgv", "unfiltered" : entry.unfiltered, "y" : entry.mgdl, "direction" : entry.direction.rawValue]
            
            return dict
        }
    }
}

extension Calibration: Chartable {
    public var chartDictionary: [String: AnyObject] {
        get{
            let entry: Calibration = self
            let dateForJson = chartDateFormatter.stringFromDate(entry.date)
            let dict: [String: AnyObject] = ["color" : chartColor, "date" : dateForJson, "slope" : entry.slope, "intercept": entry.intercept, "scale" : entry.scale]
            
            return dict
        }
    }
}

extension MeteredGlucoseValue: Chartable {
    public var chartDictionary: [String: AnyObject] {
        get{
            let entry: MeteredGlucoseValue = self
            let dateForJson = chartDateFormatter.stringFromDate(entry.date)
            let dict: [String: AnyObject] = ["color" : chartColor, "date" : dateForJson, "device" : entry.device.rawValue, "mgdl" : entry.mgdl]
            
            return dict
        }
    }
    
}