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
extension SitesDataSourceProvider {
    public var milliseconds: Double {
        return -1168583640000
    }
}


/* move to a protocal for storage conformance
public protocol StorageType {
func getSites() -> [Site]
func createSite(site: Site) -> Bool
func updateSite(site: Site)  ->  Bool
func deleteSite(atIndex: Int) -> Bool

func saveData() -> Bool
func loadData() -> Bool
}

public protocol ComplicationGenerator {
var primarySite: Site? { set get }
func createComplicationData() -> [ComplicationModel]
var oldestComplicationModel: ComplicationModel?
var latestComplicationModel: ComplicationModel?
func nearest(calibration cals: [Calibration], forDate date: NSDate) -> Calibration?
}
*/

public class SitesDataSource: SitesDataSourceProvider{
    private static let sharedAppGrouSuiteName: String = "group.com.nothingonline.nightscouter"
    
    public var sites = [Site]() {
        didSet {
            let siteDict = sites.map { $0.encode() }
            defaults.setObject(siteDict, forKey: DefaultKey.sites.rawValue)
            
            createComplicationData()
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
        
        // defaults.synchronize()
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
extension SitesDataSource {
    
    public var complicationDataFromDefaults: [ComplicationModel] {
        var complicationModels: [ComplicationModel] = complicationDataDictoinary.flatMap { ComplicationModel.decode($0) }
        complicationModels.sortByDate()
        
        return complicationModels
    }
    
    public var complicationDataDictoinary: [[String: AnyObject]] {
        set{
            defaults.setObject(newValue, forKey: DefaultKey.complicationData.rawValue)
        }
        get {
            guard let complicationDictArray =  defaults.objectForKey(DefaultKey.complicationData.rawValue) as? [[String: AnyObject]] else {
                return []
            }
            return complicationDictArray
        }
    }
    
    public var primarySite: Site? {
        return sites.filter{ $0.uuid == primarySiteUUID }.first
    }
    
    private func createComplicationData() -> [ComplicationModel] {
        guard let site = primarySite else {
            return []
        }
        
        var compModels: [ComplicationModel] = []
        
        let configuration = site.configuration ?? ServerConfiguration()
        let units = configuration.displayUnits
        let thresholds: Thresholds = configuration.settings?.thresholds ?? Thresholds(bgHigh: 300, bgLow: 70, bgTargetBottom: 60, bgTargetTop: 250)
        
        for (index, sgv) in site.sgvs.enumerate() {
            
            let sgvColor = thresholds.desiredColorState(forValue: sgv.mgdl)
            let date = sgv.date
            
            var sgvString = sgv.mgdl.formattedForMgdl
            if units == .Mmol {
                sgvString = sgv.mgdl.formattedForMmol
            }
            
            let previousIndex: Int = index + 1
            
            
            var delta: Double?
            if let previousSgv = site.sgvs[safe: previousIndex] where sgv.isSGVOk {
                delta = sgv.mgdl - previousSgv.mgdl
            }
            
            var deltaString: String = delta?.formattedForBGDelta ?? PlaceHolderStrings.delta
            //var deltaStringShort: String = ""
            if let delta = delta {
                deltaString = "\(delta.formattedForBGDelta) \(units.description)"
                //  deltaStringShort = "\(delta.formattedForBGDelta) Δ"
            }
            
            
            var rawColorVar = DesiredColorState.Neutral
            var rawString: String = ""
            if let calibration = nearest(calibration: site.cals, forDate: sgv.date) {
                
                let raw = calculateRawBG(fromSensorGlucoseValue: sgv, calibration: calibration)
                rawColorVar = thresholds.desiredColorState(forValue: raw)
                
                var rawFormattedString = raw.formattedForMgdl
                if configuration.displayUnits == .Mmol {
                    rawFormattedString = raw.formattedForMmol
                }
                
                rawString = rawFormattedString
                
                
            }
            
            let compModel = ComplicationModel(lastReadingDate: date, rawHidden: configuration.displayRawData, rawLabel: rawString, nameLabel: configuration.displayName, sgvLabel: sgvString, deltaLabel: deltaString, rawColor: rawColorVar.colorValue, sgvColor: sgvColor.colorValue, units: units, direction: sgv.direction, noise: sgv.noise)
            
            compModels.append(compModel)
        }
        
        self.complicationDataDictoinary = compModels.flatMap{ $0.encode() }
        
        return compModels
    }
    
    
    public var latestComplicationModel: ComplicationModel? {
        guard let _ = primarySite else {
            return nil
        }
        return sortByDate(complicationDataFromDefaults).first
    }
    
    public var oldestComplicationModel: ComplicationModel? {
        guard let _ = primarySite else {
            return nil
        }
        let compModel = complicationDataFromDefaults.minElement { (item1, item2) -> Bool in
            item1.lastReadingDate.timeIntervalSince1970 < item2.lastReadingDate.timeIntervalSince1970
        }
        return compModel
    }
    
    public func nearest(calibration cals: [Calibration], forDate date: NSDate) -> Calibration? {
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
            print("no valid index was found... return last calibration")
            return cals.first
        }
        return cals[safe: index]
    }
}