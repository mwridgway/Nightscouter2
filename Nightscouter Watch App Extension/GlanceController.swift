//
//  GlanceController.swift
//  Nightscouter Watch WatchKit Extension
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import WatchKit
import Foundation
import NightscouterWatchKit

class GlanceController: WKInterfaceController {
    
    @IBOutlet var lastUpdateLabel: WKInterfaceLabel!
    @IBOutlet var batteryLabel: WKInterfaceLabel!
    @IBOutlet var siteDeltaLabel: WKInterfaceLabel!
    @IBOutlet var siteRawLabel: WKInterfaceLabel!
    @IBOutlet var siteNameLabel: WKInterfaceLabel!
    
    @IBOutlet var siteSgvLabel: WKInterfaceLabel!
    var site: Site? {
        didSet {
            self.configureView()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        self.configureView()
      
        NSNotificationCenter.defaultCenter().addObserverForName(DataUpdatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            self.site = SitesDataSource.sharedInstance.primarySite
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func configureView() {
      
        guard let site = self.site else {
            return
        }
        
        let  dataSource = SiteSummaryModelViewModel(withSite: site)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            let dateString = NSCalendar.autoupdatingCurrentCalendar().stringRepresentationOfElapsedTimeSinceNow(dataSource.lastReadingDate)
            
            let formattedLastUpdateString = self.formattedStringWithHeaderFor(dateString, textColor: dataSource.lastReadingColor, textHeader: LocalizedString.lastReadingLabelShort.localized)
        
            let formattedRaw = self.formattedStringWithHeaderFor(dataSource.rawLabel, textColor: dataSource.rawColor, textHeader: LocalizedString.rawLabelShort.localized)
        
            let formattedBattery = self.formattedStringWithHeaderFor(dataSource.batteryLabel, textColor: dataSource.batteryColor, textHeader: LocalizedString.batteryLabelShort.localized)
            
            let sgvString = String(stringInterpolation:dataSource.sgvLabel, dataSource.direction.emojiForDirection)

            // Battery
            self.batteryLabel.setAttributedText(formattedBattery)
            self.lastUpdateLabel.setAttributedText(formattedLastUpdateString)
            
            // Delta
            self.siteDeltaLabel.setText(dataSource.deltaLabel)
            self.siteDeltaLabel.setTextColor(dataSource.deltaColor)
            
            // Name
            self.siteNameLabel.setText(dataSource.nameLabel)
            
            // Sgv
            self.siteSgvLabel.setText(sgvString)
            self.siteSgvLabel.setTextColor(dataSource.sgvColor)
            
            // Raw
            self.siteRawLabel.setAttributedText(formattedRaw)
            self.siteRawLabel.setHidden(dataSource.rawHidden)
        }
        
    }
    
    func formattedStringWithHeaderFor(textValue: String, textColor: UIColor, textHeader: String) -> NSAttributedString {

        let headerFontDict = [NSFontAttributeName: UIFont.boldSystemFontOfSize(8)]
        
        let headerString = NSMutableAttributedString(string: textHeader, attributes: headerFontDict)
        headerString.addAttribute(NSForegroundColorAttributeName, value: UIColor(white: 1.0, alpha: 0.5), range: NSRange(location:0,length:textHeader.characters.count))
        
        let valueString = NSMutableAttributedString(string: textValue)
        valueString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSRange(location:0,length:textValue.characters.count))
        
        headerString.appendAttributedString(valueString)
        
        return headerString
    }
}
