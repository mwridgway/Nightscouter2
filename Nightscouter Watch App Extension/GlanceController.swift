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

    @IBOutlet var compassGroup: WKInterfaceGroup!
    @IBOutlet var detailGroup: WKInterfaceGroup!
    @IBOutlet var lastUpdateLabel: WKInterfaceLabel!
    @IBOutlet var lastUpdateHeader: WKInterfaceLabel!
    @IBOutlet var batteryLabel: WKInterfaceLabel!
    @IBOutlet var batteryHeader: WKInterfaceLabel!
    @IBOutlet var compassImage: WKInterfaceImage!
    @IBOutlet var siteUpdateTimer: WKInterfaceTimer!
    
    var site: Site? {
        didSet {
            self.configureView()
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.configureView()
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
        
        guard let site = self.site, dataSource = SiteSummaryModelViewModel(withSite: site) else {
            let image = NSAssetKitWatchOS.imageOfWatchFace()
            compassImage.setImage(image)
            compassImage.setAlpha(0.5)
            
            return
        }
        
        let compassAlpha: CGFloat = dataSource.lookStale ? 0.5 : 1.0
        //let timerHidden: Bool = dataSource.lookStale
        let image = self.createImage(dataSource, delegate: dataSource, frame: calculateFrameForImage())
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            self.setTitle(dataSource.nameLabel)
            
            // Compass Image
            self.compassImage.setAlpha(compassAlpha)
            self.compassImage.setImage(image)
            
            // Battery label
            self.batteryLabel.setText(dataSource.batteryLabel)
            self.batteryLabel.setTextColor(dataSource.batteryColor)
            
            // Last reading label
            self.lastUpdateLabel.setText(PlaceHolderStrings.date)
            self.lastUpdateLabel.setTextColor(PlaceHolderStrings.defaultColor.colorValue)
            self.lastUpdateLabel.setHidden(true)
            
            self.siteUpdateTimer.setDate(dataSource.lastReadingDate)
            self.siteUpdateTimer.setTextColor(dataSource.lastReadingColor)
            self.siteUpdateTimer.setHidden(false)
        }
        
    }
    
    func calculateFrameForImage() -> CGRect {
        let frame = self.contentFrame
        let smallest = min(min(frame.height, frame.width), 134)
        let groupFrame = CGRect(x: 0, y: 0, width: smallest, height: smallest)
        
        return groupFrame
    }
    
    func createImage(dataSource:CompassViewDataSource, delegate:CompassViewDelegate, frame: CGRect) -> UIImage {
        let sgvColor = delegate.sgvColor
        let rawColor = delegate.rawColor
        
        let image = NSAssetKitWatchOS.imageOfWatchFace(arrowTintColor: sgvColor, rawColor: rawColor, isDoubleUp: dataSource.direction.isDoubleRingVisible , isArrowVisible: dataSource.direction.isArrowVisible, isRawEnabled: dataSource.rawHidden, deltaString: dataSource.deltaLabel, sgvString: dataSource.sgvLabel, rawString: dataSource.rawLabel, angle: CGFloat(dataSource.direction.angleForCompass) , watchFrame: frame)
        
        return image
    }

}
