//
//  SitesDataSource.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public protocol SitesDataSourceProvider: Dateable {
    var sites: [Site] { get }
}
public extension SitesDataSourceProvider {
    var milliseconds: Double {
        return AppConfiguration.Constant.knownMilliseconds.inThePast
    }
}

public enum StorageLocation: String {
    case LocalKeyValue, iCLoudKeyValue
}

// move to a protocol for storage conformance
public protocol StorageType {
    var storageLocation: StorageLocation { get }
    func getSites() -> [Site]
    func createSite(site: Site) -> Bool
    func updateSite(site: Site)  ->  Bool
    func deleteSite(atIndex: Int) -> Bool
    
    var lastViewedSite: Site { get }
    
    func saveData() -> Bool
    func loadData() -> Bool
}


public class SitesDataSource: SitesDataSourceProvider {
    private static let sharedAppGrouSuiteName: String = "group.com.nothingonline.nightscouter"
    
    public var sites = [Site]() {
        didSet {
            let siteDict = sites.map { $0.encode() }
            defaults.setObject(siteDict, forKey: DefaultKey.sites.rawValue)
            
            generateComplicationDataForPrimarySite()
        }
    }
    
    public var milliseconds: Mills = AppConfiguration.Constant.knownMilliseconds.inThePast
    
    public var lastViewedSiteIndex: Int {
        set {
            defaults.setInteger(newValue, forKey: DefaultKey.lastViewedSiteIndex.rawValue)
        }
        get {
            return defaults.integerForKey(DefaultKey.lastViewedSiteIndex.rawValue)
        }
    }
    
    public var lastViewedSiteUUID: NSUUID? {
        set {
            defaults.setObject(newValue?.UUIDString, forKey: DefaultKey.lastViewedSiteUUID.rawValue)
        }
        get {
            guard let uuidString = defaults.objectForKey(DefaultKey.lastViewedSiteUUID.rawValue) as? String else {
                return nil
            }
            
            return NSUUID(UUIDString: uuidString)
        }
    }
    
    public var primarySiteUUID: NSUUID? {
        set {
            defaults.setObject(newValue?.UUIDString, forKey: DefaultKey.primarySiteUUID.rawValue)
        }
        get {
            guard let uuidString = defaults.objectForKey(DefaultKey.primarySiteUUID.rawValue) as? String else {
                return nil
            }
            
            return NSUUID(UUIDString: uuidString)
        }
    }
    
    private let defaults =  NSUserDefaults(suiteName: sharedAppGrouSuiteName) ?? NSUserDefaults.standardUserDefaults()
    
    private enum DefaultKey: String, RawRepresentable {
        case sites, lastViewedSiteIndex, lastViewedSiteUUID, primarySiteUUID, complicationData
    }
    
    public static let sharedInstance = SitesDataSource()
    
    private init(){
        loadSitesFromDefaults()
    }
    
    public func loadDefaults(fromDictionary dict: [String: AnyObject]) {
        
        if let sites = dict[DefaultKey.sites.rawValue] as? [[String: AnyObject]] {
            self.sites = sites.flatMap { Site.decode($0) }
            defaults.setObject(sites, forKey: DefaultKey.sites.rawValue)
        }
        
        self.lastViewedSiteIndex = dict[DefaultKey.lastViewedSiteIndex.rawValue] as? Int ?? 0
        if let uuidString = dict[DefaultKey.lastViewedSiteUUID.rawValue] as? String, uuid = NSUUID(UUIDString: uuidString) {
            lastViewedSiteUUID = uuid
        }
        
        if let uuidString = dict[DefaultKey.primarySiteUUID.rawValue] as? String, uuid = NSUUID(UUIDString: uuidString) {
            primarySiteUUID = uuid
        } else {
            if !sites.isEmpty {
                primarySiteUUID = sites[0].uuid
            }
        }
        
    }
    
    // MARK: Persistence
    
    public func saveSitesToDefaults() {
        let siteDict = sites.map { $0.encode() }
        
        defaults.setObject(siteDict, forKey: DefaultKey.sites.rawValue)
        defaults.setInteger(lastViewedSiteIndex, forKey: DefaultKey.lastViewedSiteIndex.rawValue)
        defaults.setObject(lastViewedSiteUUID?.UUIDString, forKey: DefaultKey.lastViewedSiteUUID.rawValue)
        defaults.setObject(primarySiteUUID?.UUIDString, forKey: DefaultKey.primarySiteUUID.rawValue)
    }
    
    public func loadSitesFromDefaults() {
        if let sites = defaults.valueForKey(DefaultKey.sites.rawValue) as? [[String: AnyObject]] {
            self.sites = sites.flatMap { Site.decode($0) }
        }
        
        lastViewedSiteIndex = defaults.integerForKey(DefaultKey.lastViewedSiteIndex.rawValue)
        
        if let uuidString = defaults.stringForKey(DefaultKey.lastViewedSiteUUID.rawValue), uuid = NSUUID(UUIDString: uuidString) {
            lastViewedSiteUUID = uuid
        }
        
        if let uuidString = defaults.stringForKey(DefaultKey.primarySiteUUID.rawValue), uuid = NSUUID(UUIDString: uuidString) {
            primarySiteUUID = uuid
        } else {
            if !sites.isEmpty {
                primarySiteUUID = sites[0].uuid
            }
        }
    }
    
    // MARK: Array modification methods
    
    public func addSite(site: Site, atIndex: Int?) {
        // FIXME: The site isn't be matched correctly.
        if sites.isEmpty {
            primarySiteUUID = site.uuid
        }
        if let indexOptional = atIndex where !sites.contains(site){
            if (sites.count >= indexOptional) {
                sites.insert(site, atIndex: indexOptional )
            }
        } else {
            sites.append(site)
        }
    }
    
    public func updateSite(site: Site)  ->  Bool {
        if let index = sites.indexOf(site) {
            sites[index] = site
            return true
        }
        return false
    }
    
    public func removeSite(atIndex: Int) {
        if atIndex <= sites.count - 1 {
            let site = sites[atIndex]
            sites.removeAtIndex(atIndex)
            AppConfiguration.keychain[site.uuid.UUIDString] = nil
            
            if primarySiteUUID == site.uuid {
                primarySiteUUID = nil
            }
        }
        if sites.isEmpty {
            lastViewedSiteIndex = 0
            lastViewedSiteUUID = nil
            primarySiteUUID = nil
        }
    }
    
}

// MARK: Complication Data Source
extension SitesDataSource: ComplicationDataSourceGenerator {
//    
//     public var complicationDataDictoinary: [[String: AnyObject]] {
//        set{
//            defaults.setObject(newValue, forKey: DefaultKey.complicationData.rawValue)
//        }
//        get {
//            guard let complicationDictArray =  defaults.objectForKey(DefaultKey.complicationData.rawValue) as? [[String: AnyObject]] else {
//                return []
//            }
//            return complicationDictArray
//        }
//    }
    
    public var primarySite: Site? {
        return sites.filter{ $0.uuid == primarySiteUUID }.first
    }
    
    public func generateComplicationData(forConfiguration configuration: ServerConfiguration, sgvs:[SensorGlucoseValue], calibrations:[Calibration]) -> [ComplicationTimelineEntry] {
        
        // Init Complication Model Array for return as Timeline.
        var compModels: [ComplicationTimelineEntry] = []
        
        // Get prfered Units for site.
        let units = configuration.displayUnits
        
        // Setup thresholds for proper color coding.
        let thresholds: Thresholds = configuration.settings?.thresholds ?? Thresholds(bgHigh: 300, bgLow: 70, bgTargetBottom: 60, bgTargetTop: 250)
        
        // Iterate through provided Sensor Glucose Values to create a timeline.
        for (index, sgv) in sgvs.enumerate() {
            
            // Create a color for a given SGV value.
            let sgvColor = thresholds.desiredColorState(forValue: sgv.mgdl)
            
            // Set the date required by the Complication Data Source (for Timeline)
            let date = sgv.date
            
            // Convet Sensor Glucose Value to a proper string. Always start with a mgd/L number then convert to a mmol/L
            var sgvString = sgv.mgdl.formattedForMgdl
            if units == .Mmol {
                sgvString = sgv.mgdl.formattedForMmol
            }
            
            //
            // END of Delta Calculation
            //
            // Init Delta var.
            var delta: MgdlValue = 0
            
            // Get the next index position which would be a previous or older reading.
            let previousIndex: Int = index + 1
            // If the next index is a valid object and the number is safe.
            if let previousSgv = sgvs[safe: previousIndex] where sgv.isSGVOk {
                delta = sgv.mgdl - previousSgv.mgdl
            }
            // Convert to proper units
            if units == .Mmol {
                delta = delta.toMmol
            }
            
            // Create strings if the sgv is ok. Otherwise clear it out.
            let deltaString = sgv.isSGVOk ? "(" + delta.formattedBGDelta(forUnits: units) + ")" : ""
            
            // END of Delta Calculation
            //
            
            //
            // Start of Raw Calculation
            //
            // Init Raw String var
            var rawString: String = ""
            
            // Get nearest calibration for a given sensor glucouse value's date.
            if let calibration = nearest(calibration: calibrations, forDate: sgv.date) {
                
                // Calculate Raw BG for a given calibration.
                let raw = calculateRawBG(fromSensorGlucoseValue: sgv, calibration: calibration)
                var rawFormattedString = raw.formattedForMgdl
                // Convert to correct units.
                if units == .Mmol {
                    rawFormattedString = raw.formattedForMmol
                }
                // Create string representation of raw data.
                rawString = rawFormattedString
            }
            
            let compModel = ComplicationTimelineEntry(date: date, rawLabel: rawString, nameLabel: configuration.displayName, sgvLabel: sgvString, deltaLabel: deltaString, tintColor: sgvColor.colorValue, units: units, direction: sgv.direction, noise: sgv.noise)
            
            compModels.append(compModel)
        }
        
        
        let settings = configuration.settings ?? ServerConfiguration().settings!
        
        // Get the latest model and use to create stale complication timeline entries.
        let model = compModels.maxElement{ (lModel, rModel) -> Bool in
            return rModel.date.compare(lModel.date) == .OrderedDescending
        }
        
        if let model = model {
            // take last date and extend out 15 minutes.
            if settings.timeAgo.warn {
                let warnTime = settings.timeAgo.warnMins
                let warningStaleDate = model.date.dateByAddingTimeInterval(warnTime)
                let warnItem = ComplicationTimelineEntry(date: warningStaleDate, rawLabel: "Please update.", nameLabel: "Data missing.", sgvLabel: "Warning", deltaLabel: "", tintColor: DesiredColorState.Warning.colorValue, units: .Mgdl, direction: .None, noise: .None)
                compModels.append(warnItem)
            }
            
            if settings.timeAgo.urgent {
                // take last date and extend out 30 minutes.
                let urgentTime = settings.timeAgo.urgentMins
                let urgentStaleDate = model.date.dateByAddingTimeInterval(urgentTime)
                let urgentItem = ComplicationTimelineEntry(date: urgentStaleDate, rawLabel: "Please update.", nameLabel: "Data missing.", sgvLabel: "Urgent", deltaLabel: "", tintColor: DesiredColorState.Alert.colorValue, units: .Mgdl, direction: .None, noise: .None)
                compModels.append(urgentItem)
            }
        }
        
        compModels.sortByDate()
        
        return compModels
    }
    
    public var latestComplicationDataForPrimarySite: ComplicationTimelineEntry? {
        
        let complicationModels: [ComplicationTimelineEntry] = primarySite?.complicationTimeline ?? []

        return sortByDate(complicationModels).first
    }
    
    public var oldestComplicationDataForPrimarySite: ComplicationTimelineEntry? {
        let complicationModels: [ComplicationTimelineEntry] = primarySite?.complicationTimeline ?? []

        return sortByDate(complicationModels).last
    }
    
}

extension Site {
    mutating func generateTimeline() {
        guard let configuration = self.configuration else {
            return
        }
        
        self.complicationTimeline = SitesDataSource.sharedInstance.generateComplicationData(forConfiguration:configuration, sgvs: self.sgvs, calibrations: self.cals)
    }
}
