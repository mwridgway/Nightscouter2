//
//  SitesTableInterfaceController.swift
//  Nightscouter
//
//  Created by Peter Ina on 10/4/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import WatchKit
import NightscouterKit

class SitesTableInterfaceController: WKInterfaceController {
    
    struct ControllerName {
        static let SiteDetail: String = "SiteDetail"
    }
    
    struct RowIdentifier {
        static let rowSiteTypeIdentifier = "SiteRowController"
        static let rowEmptyTypeIdentifier = "SiteEmptyRowController"
        static let rowUpdateTypeIdentifier = "SiteUpdateRowController"
    }
    
    @IBOutlet var sitesTable: WKInterfaceTable!
    @IBOutlet var sitesLoading: WKInterfaceLabel!
    
    var sites: [Site] = [] {
        didSet {
            self.updateTableData()
        }
    }
    
    var lastUpdatedTime: NSDate? {
        didSet {
            if let date = lastUpdatedTime {
                timeStamp = AppConfiguration.lastUpdatedFromPhoneDateFormatter.stringFromDate(date)
            }
            sitesLoading.setHidden(!self.sites.isEmpty)
        }
    }
    
    var timeStamp: String = ""
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print(">>> Entering \(#function) <<<")
        
        self.updateTableData()
        
        // TODO: If there is only one site in the array, push to the detail controller right away. If a new or second one is added dismiss and return to table view.
        // TODO: Faking a data transfter date.
        // TODO: Need to update the table when data changes... also need to call updateTable if empty to show an empty row.
        NSNotificationCenter.defaultCenter().addObserverForName(DataUpdatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            self.sites = SitesDataSource.sharedInstance.sites
            self.lastUpdatedTime = NSDate()
            // self.updateTableData()
        }
        
        // WatchSessionManager.sharedManager.startSearching()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        // create object.
        // push controller...
        print(">>> Entering \(#function) <<<")
        
        SitesDataSource.sharedInstance.lastViewedSiteIndex = rowIndex
        
        // let site = sites[rowIndex]
        // let mvm = site.generateSummaryModelViewModel()
        // print(mvm)
        
        // push relevant context over to the detail page.
        pushControllerWithName(ControllerName.SiteDetail, context: [DefaultKey.lastViewedSiteIndex.rawValue: rowIndex])
    }
    
    private func updateTableData() {
        print(">>> Entering \(#function) <<<")
        
        if self.sites.isEmpty {
            
            self.sitesLoading.setHidden(true)
            
            self.sitesTable.setNumberOfRows(1, withRowType: RowIdentifier.rowEmptyTypeIdentifier)
            let row = self.sitesTable.rowControllerAtIndex(0) as? SiteEmptyRowController
            if let row = row {
                row.messageLabel.setText(LocalizedString.emptyTableViewCellTitle.localized)
            }
            
        } else {
            self.sitesLoading.setHidden(true)

            var rowSiteType = self.sites.map{ _ in RowIdentifier.rowSiteTypeIdentifier }
            rowSiteType.append(RowIdentifier.rowUpdateTypeIdentifier)
            
            self.sitesTable.setRowTypes(rowSiteType)
            
            for (index, site) in self.sites.enumerate() {
                if let row = self.sitesTable.rowControllerAtIndex(index) as? SiteRowController {
                    let mvm = site.generateSummaryModelViewModel()
                    row.configure(withDataSource: mvm, delegate: mvm)
                }
            }
            
            let updateRow = self.sitesTable.rowControllerAtIndex(self.sites.count) as? SiteUpdateRowController
            
            if let updateRow = updateRow {
                updateRow.siteLastReadingLabel.setText(self.timeStamp)
                updateRow.siteLastReadingLabelHeader.setText(LocalizedString.updateDateFromPhoneString.localized)
            }
        }
    }
    
    @IBAction func updateButton() {
        WatchSessionManager.sharedManager.requestCompanionAppUpdate()
    }
}

