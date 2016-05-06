//
//  DownloadSiteDataOperation.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import Operations
import CryptoSwift

class DownloadSiteConfigurationOperation: GroupOperation {
    // MARK: Properties
    
    let cacheFile: NSURL
    let url: NSURL
    let apiSecret: String
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the configuration JSON will be downloaded.
    init(cacheFile: NSURL, forSiteURL url: NSURL, withApiSecretString apiSecret: String) {
        self.cacheFile = cacheFile
        self.url = url
        self.apiSecret = apiSecret
        
        super.init(operations: [])
        
        name = "Download Configuration JSON for Site."
        
        let request = generateConfigurationRequestHeader(withURL: url, withApiSecretString: apiSecret)
    
        let task = NSURLSession.sharedSession().downloadTaskWithRequest(request) {url, response, error in
            self.downloadFinished(url, response: response as? NSHTTPURLResponse, error: error)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(url: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
    func downloadFinished(url: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {
        if let localURL = url {
            do {
                /*
                 If we already have a file at this location, just delete it.
                 Also, swallow the error, because we don't really care about it.
                 */
                try NSFileManager.defaultManager().removeItemAtURL(cacheFile)
            }
            catch { }
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: cacheFile)
            }
            catch let error as NSError {
                aggregateError(error)
            }
            
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
    
    private func generateConfigurationRequestHeader(withURL url: NSURL, withApiSecretString apiSecret: String) -> NSMutableURLRequest {
        var headers: [String: String] = ["Content-Type": "application/json"]
        headers["api-secret"] = apiSecret.sha1()
        let configurationURL = url.URLByAppendingPathComponent("api/v1/status").URLByAppendingPathExtension("json")
        let request = NSMutableURLRequest(URL: configurationURL)
        
        for (headerField, headerValue) in headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        return request
    }


}
