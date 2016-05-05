//
//  iCloudStore.swift
//  Nightscouter
//
//  Created by Peter Ina on 2/2/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

class iCloudKeyValueStore: NSObject, SessionManagerType {
    
    private let iCloudKeyValueStore: NSUbiquitousKeyValueStore
    
    override init() {
        iCloudKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
            object: iCloudKeyValueStore)
    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject], changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber else {
            return
        }
        
        let reason = changeReason.integerValue
        
        if (reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange) {
            let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as! [String]
            let iCloudStore = NSUbiquitousKeyValueStore.defaultStore()
            print("iCloud has the following changed keys to sync: \(changedKeys)")
            
            guard let store = store else {
                print("No Store")
                
                return
            }
            
            var syncedChanged = [String: AnyObject]()
            
            for key in changedKeys {
                // Update Data Source
                // print(key)
                // print(iCloudStore.objectForKey(key))
                syncedChanged[key] = iCloudStore.objectForKey(key)
            }
            
            store.handleApplicationContextPayload(syncedChanged)
        }
    }
    
    var store: SiteStoreType?
    
    func startSession() {
        let lazyMap = Array(iCloudKeyValueStore.dictionaryRepresentation.keys)
        print("keys in \(iCloudKeyValueStore): " + lazyMap.description)
        
        iCloudKeyValueStore.synchronize()
    }
    
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
        for (key, object) in applicationContext where key != DefaultKey.lastDataUpdateDateFromPhone.rawValue {
            iCloudKeyValueStore.setObject(object, forKey: key)
        }
        
        iCloudKeyValueStore.synchronize()
    }
    
    func requestCompanionAppUpdate() {
        
    }
}