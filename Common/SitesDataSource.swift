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
    public var milliseconds: Double = AppConfiguration.Constant.knownMilliseconds
    
    public static let sharedInstance = SitesDataSource()
    private init(){
        sites = [Site(url: NSURL(string: "https://nscgm.herokuapp.com")!, apiSecret: "")]
    }
}