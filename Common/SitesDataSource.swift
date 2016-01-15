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
}

public class SitesDataSource: SitesDataSourceProvider{
    public var sites: [Site] {
        let cal = Calibration()
        let sgv = SensorGlucoseValue()
        let de = DeviceStatus()
        
        var s1 = Site()
        var s2 = Site()
        var s3 = Site()
        s1.url = NSURL(string: "benscgm.herokuapp.com")!
        s1.sgvs.append(sgv)
        s1.deviceStatus.append(de)
        s1.sgvs.append(sgv)
        s1.cals.append(cal)
        s2.sgvs.append(sgv)
        s2.cals.append(cal)
        s3.deviceStatus.append(de)
        
        return [s1, s2]
        
    }
    public var milliseconds: Double = AppConfiguration.Constant.knownMilliseconds
    
    public init(){
        
    }
}