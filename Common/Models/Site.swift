//
//  Site.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public struct Site: Dateable, CustomStringConvertible {
    public var configuration: ServerConfiguration?
    public var milliseconds: Double
    public var url: NSURL
    public var overrideScreenLock: Bool
    public var disabled: Bool
    
    public var sgvs: [SensorGlucoseValue] = []
    public var cals: [Calibration] = []
    public var mbgs: [MeteredGlucoseValue] = []
    public var deviceStatuses: [DeviceStatus] = []
    public var complicationTimeline: [ComplicationTimelineEntry] = []
    
    // public var allowNotifications: Bool // Will be used when we support push notifications. Future addition.
    // public var treatments: [Treatment] = [] // Will be used when we support display of treatments. Future addition.
    /*
    public var nextRefreshDate: NSDate {
    let date = self.date.dateByAddingTimeInterval(60.0 * 4)
    print("iOS nextRefreshDate: " + date.description)
    return date
    }
    
    public var updateNow: Bool {
    return self.date.compare(self.nextRefreshDate) == .OrderedDescending
    }
    */
    public var uuid: NSUUID
    
    public var description: String {
        return "{ Site: { url: \(url), configuration: \(configuration), lastConnectedDate: \(date), disabled: \(disabled), numberOfSgvs: \(sgvs.count), numberOfCals: \(cals.count), , numberOfMbgs: \(mbgs.count), numberOfTimeLineEntries: \(complicationTimeline.count) } }"
    }
    
    public init(){
        self.url = NSURL(string: "https://nscgm.herokuapp.com")!
        self.configuration = ServerConfiguration()
        self.milliseconds = AppConfiguration.Constant.knownMilliseconds
        self.overrideScreenLock = false
        self.disabled = false
        self.uuid = NSUUID()
    }
    
    public init(url: NSURL){
        self.configuration = nil
        self.milliseconds = NSDate().timeIntervalSince1970.millisecond
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        
        self.uuid = NSUUID()
    }
    
    /**
     Resets the underlying identity of the `Site`. If a copy of this item is made, and a call
     to refreshIdentity() is made afterward, the items will no longer be equal.
     */
    public mutating func refreshIdentity() {
        self.uuid = NSUUID()
    }
}

extension Site: Equatable { }
public func ==(lhs: Site, rhs: Site) -> Bool {
    return lhs.uuid == rhs.uuid && lhs.url == rhs.url
}

extension Site: Hashable {
    public var hashValue: Int {
        return uuid.hashValue + sgvs.count.hashValue + cals.count.hashValue + deviceStatuses.count.hashValue
    }
}

extension Site {
    /**
     This is the string provided by the user in the intial creation of a site.
     It must be converted to a SHA1 string before use in communicating with a server.
     */
    public var apiSecret: String {
        set{
            // write to keychain
            AppConfiguration.keychain[uuid.UUIDString] = newValue
        }
        get{
            return AppConfiguration.keychain[uuid.UUIDString] ?? ""
        }
    }
    
    public init(url: NSURL, apiSecret: String){
        self.configuration = nil
        self.milliseconds = NSDate().timeIntervalSince1970.millisecond
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        self.uuid = NSUUID()
        
        self.apiSecret = apiSecret
    }
    
    public init(url: NSURL, uuid: NSUUID){
        self.configuration = nil
        self.milliseconds = NSDate().timeIntervalSince1970.millisecond
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        self.uuid = uuid
        
        self.apiSecret = AppConfiguration.keychain[uuid.UUIDString] ?? ""
    }
}

extension Site {
    public func generateSummaryModelViewModel() -> SiteSummaryModelViewModel {
        return SiteSummaryModelViewModel(withSite: self)
    }
}