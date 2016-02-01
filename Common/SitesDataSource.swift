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
        return 1168583640000
    }
}

public class SitesDataSource: SitesDataSourceProvider{
    private static let sharedAppGrouSuiteName: String = "group.com.nothingonline.nightscouter"
    
    public var sites = [Site]()
    
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
        didSet {
            if let uuid = sites.first?.uuid where primarySiteUUID == nil{
                primarySiteUUID = uuid
            }
            saveSitesToDefaults()
        }
    }
    
    private let defaults =  NSUserDefaults(suiteName: sharedAppGrouSuiteName) ?? NSUserDefaults.standardUserDefaults()
    
    private enum DefaultKey: String, RawRepresentable {
        case sites, lastViewedSiteIndex, lastViewedSiteUUID, primarySiteUUID
    }
    
    public static let sharedInstance = SitesDataSource()
 
    private init(){
        loadSitesFromDefaults()
    }
    
    // MARK: Persistence
    
    public func saveSitesToDefaults() {
        let siteDict = sites.map { $0.encode() }
        
        defaults.setObject(siteDict, forKey: DefaultKey.sites.rawValue)
        defaults.setInteger(lastViewedSiteIndex, forKey: DefaultKey.lastViewedSiteIndex.rawValue)
        defaults.setObject(lastViewedSiteUUID?.UUIDString, forKey: DefaultKey.lastViewedSiteUUID.rawValue)
        defaults.setObject(primarySiteUUID?.UUIDString, forKey: DefaultKey.primarySiteUUID.rawValue)
        
        defaults.synchronize()
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
            primarySiteUUID = sites[0].uuid
        }
        
    }
    
    // MARK: Array modification methods
    
    public func addSite(site: Site, atIndex: Int?) {
        defer {
            saveSitesToDefaults()
         
        }
        
        // FIXME: The site isn't be matched correctly.
        
        if let indexOptional = atIndex where !sites.contains(site){
            if (sites.count >= indexOptional) {
                sites.insert(site, atIndex: indexOptional )
            }
        } else {
            sites.append(site)
        }
    }
    
    public func updateSite(site: Site)  ->  Bool {
        
        defer {
            saveSitesToDefaults()
        }
        
        if let index = sites.indexOf(site) {
            sites[index] = site
            return true
        }
        return false
    }
    
    public func removeSite(atIndex: Int) {
        defer {
            saveSitesToDefaults()
        }
        
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
    
    
    public func createComplicationData() {
        guard let site = sites.filter({ $0.uuid == primarySiteUUID }).first else {
            return
        }
        
        print(site)
    }
}