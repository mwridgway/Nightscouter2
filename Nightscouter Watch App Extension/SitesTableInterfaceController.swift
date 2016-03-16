//
//  SitesTableInterfaceController.swift
//  Nightscouter
//
//  Created by Peter Ina on 10/4/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import WatchKit
import NightscouterWatchKit

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
    
    //    var sites: [Site] {
    //        return SitesDataSource.sharedInstance.sites
    //    }
    
    var sites = [Site]()  {
        didSet {
            updateTableData()
        }
    }
    
    var lastUpdatedTime: NSDate? {
        didSet{
            
            if let date = lastUpdatedTime {
                timeStamp = AppConfiguration.lastUpdatedFromPhoneDateFormatter.stringFromDate(date)
            }
            
            // sitesLoading.setHidden(!self.sites.isEmpty)
            
            // updateTableData()
        }
    }
    
    var timeStamp: String = ""
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print(">>> Entering \(__FUNCTION__) <<<")
        
        // TODO: Remove once we get a real datasource hooked up.
        sites = SitesDataSource.sharedInstance.sites
        
        // TODO: Need to update the table when data changes... also need to call updateTable if empty to show an empty row.
        if sites.isEmpty { updateTableData() }
        
        // TODO: If there is only one site in the array, push to the detail controller right away. If a new or second one is added dismiss and return to table view.
        
        
        // TODO: Faking a data transfter date.
        lastUpdatedTime = NSDate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        // create object.
        // push controller...
        print(">>> Entering \(__FUNCTION__) <<<")
        let site = sites[rowIndex]
        let mvm = site.generateSummaryModelViewModel()
        
        print(mvm)
        // push relevant context over to the detail page.
        pushControllerWithName(ControllerName.SiteDetail, context: ["mvm" :  ""])
        
    }
    
    private func updateTableData() {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            print(">>> Entering \(__FUNCTION__) <<<")
            
            if self.sites.isEmpty {
                
                // self.sitesLoading.setHidden(true)
                
                self.sitesTable.setNumberOfRows(1, withRowType: RowIdentifier.rowEmptyTypeIdentifier)
                let row = self.sitesTable.rowControllerAtIndex(0) as? SiteEmptyRowController
                if let row = row {
                    row.messageLabel.setText(LocalizedString.emptyTableViewCellTitle.localized)
                }
                
            } else {
                
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
                    updateRow.siteLastReadingLabelHeader.setText("LAST UPDATE FROM PHONE")
                }
                
            }
        }
    }
    
    @IBAction func updateButton() {
        
    }
}

