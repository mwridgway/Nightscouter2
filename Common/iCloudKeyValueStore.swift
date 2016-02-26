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
    private let iCloudKeyValueStore: NSUbiquitousKeyValueStore
    
    init () {
        iCloudKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "ubiquitousKeyValueStoreDidChange:",
            name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
            object: iCloudKeyValueStore)
        
        iCloudKeyValueStore.synchronize()
    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject], changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber else {
            return
        }
        
        let reason = changeReason.integerValue
        
        if (reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange) {
            let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as! [String]
            let store = NSUbiquitousKeyValueStore.defaultStore()
            
            for key in changedKeys {
                
                // Update Data Source
                
                print(key)
                print(store.objectForKey(key))
                //                if key == DefaultKey.modelArrayObjectsKey {
                //                    if let models = store.arrayForKey(DefaultKey.modelArrayObjectsKey) as? [[String : AnyObject]] {
                //                        sites = models.flatMap( { WatchModel(fromDictionary: $0)?.generateSite() } )
                //                    }
                //                }
            }
        }
    }
}