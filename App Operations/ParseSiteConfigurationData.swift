//
//  ParseSiteConfigurationData.swift
//  Nightscouter
//
//  Created by Peter Ina on 5/5/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import Operations
import NightscouterKit

class ParseSiteConfigurationData: Operation, ResultOperationType {
    
    let cacheFile: NSURL
    var site: Site
    
    private(set) var result: ServerConfiguration?
    
    init(cacheFile: NSURL, forSite site: Site) {
        print(#function)
        
        self.cacheFile = cacheFile
        self.site = site
        super.init()
        
        name = "Parse Site Configuration Data"
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        guard let stream = NSInputStream(URL: cacheFile) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithStream(stream, options: []) as? [String: AnyObject]
            
            if let features = json {
                parse(features)
            }
            else {
                finish()
            }
        }
        catch let jsonError as NSError {
            finish([jsonError])
        }
    }
    
    private func parse(features: [String: AnyObject]) {
        let configuraiton = ServerConfiguration.decode(features)
        result = configuraiton
        
        self.site.configuration = configuraiton
        SitesDataSource.sharedInstance.updateSite(self.site)

        finish()
    }
    
}
