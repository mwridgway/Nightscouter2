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
    
    @IBOutlet var sitesTable: WKInterfaceTable!

//    var sites: [Site] {
//        return SitesDataSource.sharedInstance.sites
//    }

    var sites = [Site]()  {
        didSet {
            updateTableData()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print(">>> Entering \(__FUNCTION__) <<<")
        
        // TODO: Remove once we get a real datasource hooked up.
        sites = SitesDataSource.sharedInstance.sites
        
        // TODO: Need to update the table when data changes... also need to call updateTable if empty to show an empty row.
        if sites.isEmpty { updateTableData() }
        
        // TODO: If there is only one site in the array, push to the detail controller right away. If a new or second one is added dismiss and return to table view.
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
            
            let rowTypeIdentifier: String = "SiteRowController"
            
            if self.sites.isEmpty {
                self.sitesTable.setNumberOfRows(1, withRowType: "SiteEmptyRowController")
                let row = self.sitesTable.rowControllerAtIndex(0) as? SiteEmptyRowController
                if let row = row {
                    row.messageLabel.setText("No sites availble.")
                }
                
            } else {
                self.sitesTable.setNumberOfRows(self.sites.count, withRowType: rowTypeIdentifier)
                for (index, site) in self.sites.enumerate() {
                    if let row = self.sitesTable.rowControllerAtIndex(index) as? SiteRowController {
                        let mvm = site.generateSummaryModelViewModel()
                        row.configure(withDataSource: mvm, delegate: mvm)
                        
                    }
                }
                
            }
        }
    }
    
    @IBAction func updateButton() {
        
    }
}

