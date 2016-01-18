//
//  SiteRowController.swift
//  Nightscouter
//
//  Created by Peter Ina on 10/4/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import WatchKit
import NightscouterWatchKit

class SiteRowController: NSObject {
    @IBOutlet var siteNameLabel: WKInterfaceLabel!
    @IBOutlet var siteRawGroup: WKInterfaceGroup!
    
    @IBOutlet var siteLastReadingHeader: WKInterfaceLabel!
    @IBOutlet var backgroundGroup: WKInterfaceGroup!
    @IBOutlet var siteLastReadingLabel: WKInterfaceLabel!
    
    @IBOutlet var siteBatteryHeader: WKInterfaceLabel!
    @IBOutlet var siteBatteryLabel: WKInterfaceLabel!
    
    @IBOutlet var siteRawHeader: WKInterfaceLabel!
    @IBOutlet var siteRawLabel: WKInterfaceLabel!
    
    @IBOutlet var siteSgvLabel: WKInterfaceLabel!
    @IBOutlet var siteDeltaLabel: WKInterfaceLabel!
    
    @IBOutlet var siteUpdateTimer: WKInterfaceTimer!
    
    private var dataSource: TableViewRowWithOutCompassDataSource?
    private var delegate: TableViewRowWithOutCompassDelegate?
    
    func configure(withDataSource dataSource: TableViewRowWithOutCompassDataSource, delegate: TableViewRowWithOutCompassDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
        
        // let timerHidden: Bool = dataSource.lookStale

        // Last reading label
        siteLastReadingLabel.setText(PlaceHolderStrings.date)
        siteLastReadingLabel.setTextColor(PlaceHolderStrings.defaultColor.colorValue)
        siteLastReadingLabel.setHidden(true)
        
        siteUpdateTimer.setDate(dataSource.lastReadingDate)
        siteUpdateTimer.setTextColor(delegate?.lastReadingColor)
        siteUpdateTimer.setHidden(false)

        // Battery label
        siteBatteryLabel.setText(dataSource.batteryLabel)
        siteBatteryLabel.setTextColor(delegate?.batteryColor)
        
        // Raw data
        siteRawGroup.setHidden(dataSource.rawHidden)
        siteRawLabel.setText(dataSource.rawLabel)
        siteRawLabel.setTextColor(delegate?.rawColor)
        
        let sgvString = dataSource.sgvLabel + " " + dataSource.direction.emojiForDirection
        // SGV formatted value
        siteSgvLabel.setText(sgvString)
        siteSgvLabel.setTextColor(delegate?.sgvColor)
        
        // Delta
        siteDeltaLabel.setText(dataSource.deltaLabel)
        siteDeltaLabel.setTextColor(delegate?.deltaColor)
        
        backgroundGroup.setBackgroundColor(delegate?.sgvColor.colorWithAlphaComponent(0.2))
        
    }
}

