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
    public var sites: [Site]
    public var lastViewedSiteIndex = 0
    public var lastViewedSiteUUID: NSUUID?
    public var siteForComplication: NSUUID?
    //public var milliseconds: Double = AppConfiguration.Constant.knownMilliseconds
    
    public static let sharedInstance = SitesDataSource()
    private init(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sites = userDefaults.valueForKey("sites") as? [Site] {
            self.sites = sites
        } else {
            // add default data
            sites = []
        }
    }
    
    public func addSite(site: Site, atIndex: Int?) {
        if let indexOptional = atIndex {
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
        // let siteToBeRemoved = sites[index]
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