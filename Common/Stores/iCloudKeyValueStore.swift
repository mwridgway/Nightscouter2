//
//  iCloudStore.swift
//  Nightscouter
//
//  Created by Peter Ina on 2/2/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

class iCloudKeyValueStore {
    // MARK: iCloud Key Store Changed
    private let iCloudKeyValueStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()

    
//    init() {
//        iCloudKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
//        
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: "ubiquitousKeyValueStoreDidChange:",
//            name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
//            object: iCloudKeyValueStore)
//        
//        iCloudKeyValueStore.synchronize()
//    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject], changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber else {
            return
        }
        
        let reason = changeReason.integerValue
        
        if (reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange) {
            let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as! [String]
            let iCloudStore = NSUbiquitousKeyValueStore.defaultStore()
           
            guard let store = store else {
                print("No Store")
                
                return
            }
            
            var syncedChanged = [String: AnyObject]()
            for key in changedKeys {
                // Update Data Source
                print(key)
                print(iCloudStore.objectForKey(key))
                syncedChanged[key] = iCloudStore.objectForKey(key)
            }
            
            store.handleApplicationContextPayload(syncedChanged)
        }
    }
    
    var store: SiteStoreType?
}

extension iCloudKeyValueStore: SessionManagerType {
    
    func startSession() {
        let lazyMap = Array(iCloudKeyValueStore.dictionaryRepresentation.keys)
        print("keys in \(iCloudKeyValueStore): " + lazyMap.description)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "ubiquitousKeyValueStoreDidChange:",
            name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
            object: iCloudKeyValueStore)
        
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