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
    
    public var primarySite: Site? {
        return sites.filter{ $0.uuid == primarySiteUUID }.first
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
    
    public func updateSite(site: Site)  ->  Void {
        sites.insertOrUpdate(site)
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