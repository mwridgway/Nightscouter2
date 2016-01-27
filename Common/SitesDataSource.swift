//
//  SitesDataSource.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
//import SwiftyJSON

public protocol SitesDataSourceProvider: Dateable {
    var sites: [Site] { get }
    var lastViewedSiteIndex: Int { get }
}

extension SitesDataSourceProvider {
    public var milliseconds: Double {
        return 1168583640000
    }
    public var lastViewedSiteIndex: Int {
        return 0
    }
}

public class SitesDataSource: SitesDataSourceProvider{
    public var sites = [Site]()
    public var lastViewedSiteIndex: Int? {
        didSet {
            saveSitesToDefaults()
        }
    }
    public var lastViewedSiteUUID: NSUUID? {
        didSet {
            saveSitesToDefaults()
        }
    }
    public var siteForComplication: NSUUID? {
        didSet {
            if let uuid = sites.first?.uuid where siteForComplication == nil{
                siteForComplication = uuid
            }
            saveSitesToDefaults()
        }
    }
    //public var milliseconds: Double = AppConfiguration.Constant.knownMilliseconds
    
    public static let sharedInstance = SitesDataSource()
    
    public let defaults =  NSUserDefaults.standardUserDefaults()
    
    enum DefaultKey: String, RawRepresentable {
        case sites,lastViewedSiteIndex,lastViewedSiteUUID, siteForComplication
    }
    
    private init(){
        loadSitesFromDefaults()
    }
    
    // MARK: Persistence
    
    public func saveSitesToDefaults() {
        let siteDict = sites.map { $0.encode() }
        defaults.setObject(siteDict, forKey: DefaultKey.sites.rawValue)
        
        defaults.setInteger(lastViewedSiteIndex, forKey: DefaultKey.lastViewedSiteIndex.rawValue)
        defaults.setObject(lastViewedSiteUUID?.UUIDString, forKey: DefaultKey.lastViewedSiteUUID.rawValue)
        defaults.setObject(siteForComplication?.UUIDString, forKey: DefaultKey.siteForComplication.rawValue)
        
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
        
        if let uuidString = defaults.stringForKey(DefaultKey.siteForComplication.rawValue), uuid = NSUUID(UUIDString: uuidString) {
            siteForComplication = uuid
        }
        
    }
    
    // MARK: Array modification methods
    
    public func addSite(site: Site, atIndex: Int?) {
        defer {
            saveSitesToDefaults()
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
            sites.removeAtIndex(atIndex)
        }
        
        if sites.isEmpty {
            lastViewedSiteIndex = 0
            lastViewedSiteUUID = nil
            siteForComplication = nil
        }
    }
}