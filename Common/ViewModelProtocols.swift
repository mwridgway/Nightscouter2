//
//  ViewModelProtocols.swift
//  Nightscouter
//
//  Created by Peter Ina on 3/10/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public protocol SiteCommonInfoDataSource {
    var lastReadingDate: NSDate { get }
    var nameLabel: String { get }
    var urlLabel: String { get }
    var sgvLabel: String { get }
    var deltaLabel: String { get }
}

public protocol BatteryDataSource {
    var batteryLabel: String { get }
}
public protocol BatteryDelegate {
    var batteryColor: Color { get }
}

public protocol SiteStaleDataSource {
    var lookStale: Bool { get }
}

public protocol RawDataSource {
    var rawHidden: Bool { get }
    var rawLabel: String { get }
    var rawNoise: Noise { get }
    
    var rawFormatedLabel: String { get }
}

public extension RawDataSource {
    var rawFormatedLabel: String {
        return "\(rawLabel) : \(rawNoise.description)"
    }
    var rawFormatedLabelShort: String {
        return "\(rawLabel) : \(rawNoise.description[rawNoise.description.startIndex])"
    }
}

public protocol RawDelegate {
    var rawColor: Color { get }
}

public protocol SiteCommonInfoDelegate {
    var lastReadingColor: Color { get }
    var sgvColor: Color { get }
    var deltaColor: Color { get }
}

public protocol DirectionDisplayable {
    var direction: Direction { get }
}

public protocol CompassViewDataSource: SiteCommonInfoDataSource, SiteStaleDataSource, DirectionDisplayable, RawDataSource {
    var text: String { get }
    var detailText: String { get }
}

public protocol CompassViewDelegate: SiteCommonInfoDelegate, RawDelegate {
    var desiredColor: DesiredColorState { get }
}

public typealias TableViewRowWithCompassDataSource = protocol<SiteCommonInfoDataSource, BatteryDataSource, CompassViewDataSource>
public typealias TableViewRowWithCompassDelegate = protocol<SiteCommonInfoDelegate, CompassViewDelegate, BatteryDelegate>

public typealias TableViewRowWithOutCompassDataSource = protocol<SiteCommonInfoDataSource, BatteryDataSource, RawDataSource, DirectionDisplayable>
public typealias TableViewRowWithOutCompassDelegate = protocol<SiteCommonInfoDelegate, RawDelegate, BatteryDelegate>

public typealias SiteSummaryModelViewModelDataSource = protocol<SiteCommonInfoDataSource, RawDataSource, BatteryDataSource, DirectionDisplayable, CompassViewDataSource>
public typealias SiteSummaryModelViewModelDelegate = protocol<BatteryDelegate, RawDelegate, SiteCommonInfoDelegate, CompassViewDelegate>
