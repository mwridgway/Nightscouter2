//
//  SitesDataSource.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public enum DefaultKey: String, RawRepresentable {
    case sites, lastViewedSiteIndex, primarySiteUUID, lastDataUpdateDateFromPhone, updateData, action, error
    
    static var payloadPhoneUpdate: [String : String] {
        return [DefaultKey.action.rawValue: DefaultKey.updateData.rawValue]
    }
    
    static var payloadPhoneUpdateError: [String : String] {
        return [DefaultKey.action.rawValue: DefaultKey.error.rawValue]
    }
}

public class SitesDataSource: SiteStoreType {

    public static let sharedInstance = SitesDataSource()
    
    private init() {
        self.defaults = NSUserDefaults(suiteName: AppConfiguration.sharedApplicationGroupSuiteName ) ?? NSUserDefaults.standardUserDefaults()
        
        let watchConnectivityManager = WatchSessionManager.sharedManager
        watchConnectivityManager.store = self
        watchConnectivityManager.startSession()
        
        let iCloudManager = iCloudKeyValueStore()
        iCloudManager.store = self
        iCloudManager.startSession()
        
        self.sessionManagers = [watchConnectivityManager, iCloudManager]
    }
    
    private let defaults: NSUserDefaults
    
    private var sessionManagers: [SessionManagerType] = []
    
    public var storageLocation: StorageLocation { return .LocalKeyValueStore }
    
    public var otherStorageLocations: SiteStoreType?
    
    public var sites: [Site] {
        if let loaded = loadData() {
            return loaded
        }
        return []
    }
    
    public var lastViewedSiteIndex: Int {
        get {
            return defaults.objectForKey(DefaultKey.lastViewedSiteIndex.rawValue) as? Int ?? 0
        }
        set {
            if lastViewedSiteIndex != newValue {
                saveData([DefaultKey.lastViewedSiteIndex.rawValue: newValue])
            }
        }
    }
    
    public var primarySite: Site? {
        set{
            if let site = newValue {
                saveData([DefaultKey.primarySiteUUID.rawValue: site.uuid.UUIDString])
            }
        }
        get {
            if let uuidString = defaults.objectForKey(DefaultKey.primarySiteUUID.rawValue) as? String {
                return sites.filter { $0.uuid.UUIDString == uuidString }.first
            } else if let firstSite = sites.first {
                return firstSite
            }
            return nil
        }
    }
    
    // MARK: Array modification methods
    public func createSite(site: Site, atIndex index: Int?) -> Bool {
        var initial: [Site] = self.sites
        
        if initial.isEmpty {
            primarySite = site
        }
        
        if let index = index {
            initial.insert(site, atIndex: index)
        } else {
            initial.append(site)
        }
        
        
        let siteDict = initial.map { $0.encode() }
        
        saveData([DefaultKey.sites.rawValue: siteDict])
        
        return initial.contains(site)
    }
    
    public func updateSite(site: Site)  ->  Bool {
        
        var initial = sites
        
        let success = initial.insertOrUpdate(site)
        
        let siteDict = initial.map { $0.encode() }
        
        saveData([DefaultKey.sites.rawValue: siteDict])
        
        return success
    }
    
    public func deleteSite(site: Site) -> Bool {
        
        var initial = sites
        let success = initial.remove(site)
        
        AppConfiguration.keychain[site.uuid.UUIDString] = nil
       
        if site == lastViewedSite {
            lastViewedSiteIndex = 0
        }
        
        if sites.isEmpty {
            lastViewedSiteIndex = 0
            primarySite = nil
        }
        
        let siteDict = initial.map { $0.encode() }
        saveData([DefaultKey.sites.rawValue: siteDict])
        
        return success
    }
    
    public func clearAllSites() -> Bool {
        var initial = sites
        initial.removeAll()
        
        saveData([DefaultKey.sites.rawValue: []])
        
        return initial.isEmpty
    }
    
    public func handleApplicationContextPayload(payload: [String : AnyObject]) {
        
        if let sites = payload[DefaultKey.sites.rawValue] as? ArrayOfDictionaries {
            defaults.setObject(sites, forKey: DefaultKey.sites.rawValue)
        } else {
            print("No sites were found.")
        }
        
        if let lastViewedSiteIndex = payload[DefaultKey.lastViewedSiteIndex.rawValue] as? Int {
            self.lastViewedSiteIndex = lastViewedSiteIndex
        } else {
            print("No lastViewedIndex was found.")
        }
        
        if let uuidString = payload[DefaultKey.primarySiteUUID.rawValue] as? String {
            self.primarySite = sites.filter{ $0.uuid.UUIDString == uuidString }.first
        } else {
            print("No primarySiteUUID was found.")
        }
        
        #if os(watchOS)
            if let lastDataUpdateDateFromPhone = payload[DefaultKey.lastDataUpdateDateFromPhone.rawValue] as? NSDate {
                //defaults.setObject(lastDataUpdateDateFromPhone,forKey: DefaultKey.lastDataUpdateDateFromPhone.rawValue)
            }
        #endif
        
        if let action = payload[DefaultKey.action.rawValue] as? String {
            if action == DefaultKey.updateData.rawValue {
                print("found an action: \(action)")
                for site in sites {
                    #if os(iOS)
                        print(site.url.description + " " + site.uuid.UUIDString)
                        dispatch_async(dispatch_get_main_queue()) {
//                            let socket = NightscoutSocketIOClient(site: site)
//                            socket.fetchConfigurationData().startWithNext { racSite in
//                                // if let racSite = racSite {
//                                // self.updateSite(racSite)
//                                // }
//                            }
//                            socket.fetchSocketData().observeNext { racSite in
//                                self.updateSite(racSite)
//                            }
                        }
                    #endif
                }
            } else if action == DefaultKey.error.rawValue {
                print("Received an error.")
                
            } else {
                print("Did not find an action.")
            }
        }
        
        defaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DataUpdatedNotification, object: nil)
    }
    
    public func loadData() -> [Site]? {
        
        if let sites = defaults.arrayForKey(DefaultKey.sites.rawValue) as? ArrayOfDictionaries {
            return sites.flatMap { Site.decode($0) }
        }
        
        return []
    }
    
    public func saveData(dictionary: [String: AnyObject]) -> (savedLocally: Bool, updatedApplicationContext: Bool) {
        
        var dictionaryToSend = dictionary
        
        var successfullSave: Bool = false
        
        for (key, object) in dictionaryToSend {
            defaults.setObject(object, forKey: key)
        }
        
        dictionaryToSend[DefaultKey.lastDataUpdateDateFromPhone.rawValue] = NSDate()
        
        successfullSave = defaults.synchronize()
        
        var successfullAppContextUpdate = true
        
        sessionManagers.forEach({ (manager: SessionManagerType ) -> () in
            do {
                try manager.updateApplicationContext(dictionaryToSend)
            } catch {
                successfullAppContextUpdate = false
                fatalError("Something didn't go right, create a fix.")
            }
        })
        
        return (successfullSave, successfullAppContextUpdate)
    }
}
