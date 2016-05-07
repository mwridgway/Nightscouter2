//
//  GetSiteDataOperation.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import Operations
import NightscouterKit
import SocketIOClientSwift
class GetSiteDataOperation: GroupOperation {
    
    let downloadSiteConfigurationOperation: DownloadSiteConfigurationOperation
    let parseSiteConfigurationData: ParseSiteConfigurationData
    
    private var hasProducedAlert = false
    
    init(withSites site:Site,  completionHandler: Void -> Void) {

        let cachesFolder = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        let cacheFile = cachesFolder.URLByAppendingPathComponent("\(site.uuid).json")
        
        /*
         This operation is made of three child operations:
         1. The operation to download the JSON feed
         2. The operation to parse the JSON feed and insert the elements into the Core Data store
         3. The operation to invoke the completion handler
         */
        downloadSiteConfigurationOperation = DownloadSiteConfigurationOperation(cacheFile: cacheFile, forSiteURL: site.url, withApiSecretString: site.apiSecret)
        parseSiteConfigurationData = ParseSiteConfigurationData(cacheFile: cacheFile, forSite: site)
        // These operations must be executed in order
        parseSiteConfigurationData.addDependency(downloadSiteConfigurationOperation)
        
//        let client = SocketIOClient(socketURL: site.url)
//        let socketIOOperation = SocketIOOperation(socketClient: client, apiSecret: site.apiSecret) { (json) in
//            var newSite = site
//            newSite.parseJSONforSocketData(json)
//            
//            SitesDataSource.sharedInstance.updateSite(newSite)
//        }
//        socketIOOperation.addDependency(parseSiteConfigurationData)


        let finishOperation = NSBlockOperation(block: completionHandler)
        finishOperation.addDependency(parseSiteConfigurationData)

        
        super.init(operations: [downloadSiteConfigurationOperation, parseSiteConfigurationData, finishOperation])
        
        name = "Get Nightscout Data"
    }
}