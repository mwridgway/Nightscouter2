//
//  SitesTableViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/13/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit
import ReactiveCocoa
import Operations

class SitesTableViewController: UITableViewController, SitesDataSourceProvider, SegueHandlerType {
    
    let operationQueue = OperationQueue()
    
    struct CellIdentifier {
        static let SiteTableViewStyleLarge = "siteCellLarge"
    }
    
    enum SegueIdentifier: String {
        case EditExisting, ShowDetail, AddNew, AddNewWhenEmpty, LaunchLabs, ShowPageView, UnwindToSiteList
    }
    
    var sites: [Site] {
        return SitesDataSource.sharedInstance.sites
    }
    
    var milliseconds: Double = 0 {
        didSet{
            let str = String(stringInterpolation:LocalizedString.lastUpdatedDateLabel.localized, AppConfiguration.lastUpdatedDateFormatter.stringFromDate(date))
            self.refreshControl?.attributedTitle = NSAttributedString(string:str, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    /**
     Holds the indexPath of an accessory that was tapped.
     Used for triggering a transition into edit mode.
     */
    var accessoryIndexPath: NSIndexPath?
    
    /**
     Array of HTTP Clients
     */
    //    var sockets = [NightscoutSocketIOClient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Common setup.
        configureView()
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(DataUpdatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateData()
        
        // Check if we should display a form.
        shouldIShowNewSiteForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sites.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.SiteTableViewStyleLarge, forIndexPath: indexPath) as! SiteTableViewCell
        
        let model = sites[indexPath.row].generateSummaryModelViewModel()
        cell.configure(withDataSource: model, delegate: model)
        
        return cell
    }
    
    // MARK: Table wiew delegate
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let highlightView = UIView()
        highlightView.backgroundColor = NightscouterAssetKit.darkNavColor
        cell?.selectedBackgroundView = highlightView
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete object form data source.
            SitesDataSource.sharedInstance.deleteSite(sites[indexPath.row])
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // If the site array is empty show add form.
            shouldIShowNewSiteForm()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // Pull the site that was moved from the data source at its current (fromIndexPath) location.
        let site = sites[fromIndexPath.row]
        
        // Remove the site from the data source from its orginal (fromIndexPath) location.
        SitesDataSource.sharedInstance.deleteSite(sites[fromIndexPath.row])
        
        //        SitesDataSource.sharedInstance.removeSite(fromIndexPath.row)
        // Insert the site into the data source at its new (toIndexPath) location.
        SitesDataSource.sharedInstance.createSite(site, atIndex: toIndexPath.row)
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        if sites.count == 1 { return false }
        return true
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        accessoryIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return LocalizedString.tableViewCellRemove.localized
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segueIdentifierForSegue(segue) {
            
        case .EditExisting:
            #if DEBUG
                print("Editing existing site", terminator: "")
            #endif
            editing = false
            let siteDetailViewController = segue.destinationViewController as! FormViewController
            // Get the cell that generated this segue.
            if let selectedSiteCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSiteCell)!
                let selectedSite = sites[indexPath.row]
                
                SitesDataSource.sharedInstance.lastViewedSiteIndex = indexPath.row
                siteDetailViewController.site = selectedSite
            }
            
        case .AddNew:
            #if DEBUG
                print("Adding new site", terminator: "")
            #endif
            self.setEditing(false, animated: true)
            
        case .AddNewWhenEmpty:
            #if DEBUG
                print("Adding new site when empty", terminator: "")
            #endif
            self.setEditing(false, animated: true)
            return
            
        case .ShowDetail:
            let siteDetailViewController = segue.destinationViewController as! SiteDetailViewController
            // Get the cell that generated this segue.
            if let selectedSiteCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSiteCell)!
                let selectedSite = sites[indexPath.row]
                siteDetailViewController.site = selectedSite
            }
            
        case .ShowPageView:
            // let siteListPageViewController = segue.destinationViewController as! SiteListPageViewController
            // Get the cell that generated this segue.
            if let selectedSiteCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSiteCell) ?? NSIndexPath(forItem: 0, inSection: 0)
                SitesDataSource.sharedInstance.lastViewedSiteIndex = indexPath.row
            }
            
            if let incomingSite = sender as? Site{
                if let indexOfSite = sites.indexOf(incomingSite) {
                    SitesDataSource.sharedInstance.lastViewedSiteIndex = indexOfSite
                }
            }
            
        default:
            #if DEBUG
                print("Unhandled segue idendifier: \(segue.identifier)", terminator: "")
            #endif
        }
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func refreshTable( sender: UIRefreshControl) {
        updateData()
    }
    
    @IBAction func unwindToSiteList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as? FormViewController, site = sourceViewController.site {
            
            // This segue is triggered when we "save" or "next" out of the url form.
            if sites.contains(site) {
                guard let selectedIndex = sites.indexOf(site) else {
                    return
                }
                
                let selectedIndexPath = NSIndexPath(forRow: selectedIndex, inSection: 0)
                // Update an existing site.
                SitesDataSource.sharedInstance.updateSite(site)
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                accessoryIndexPath = nil
            } else {
                // Add a new site.
                editing = false
                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                SitesDataSource.sharedInstance.createSite(site, atIndex: newIndexPath.row)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                accessoryIndexPath = nil
            }
        }
        
        if let pageViewController = sender.sourceViewController as? SiteListPageViewController {
            // let modelController = pageViewController.modelController
            // let site = modelController.sites[pageViewController.lastViewedSiteIndex]
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: pageViewController.lastViewedSiteIndex, inSection: 0)], withRowAnimation: .Automatic)
        }
        
        shouldIShowNewSiteForm()
    }
    
    // MARK: Private Methods
    func configureView() -> Void {
        // The following line displys an Edit button in the navigation bar for this view controller.
        navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Only allow the edit button to be enabled if there are items in the sites array.
        clearsSelectionOnViewWillAppear = true
        
        // Configure table view properties.
        tableView.rowHeight = UITableViewAutomaticDimension//240
        tableView.estimatedRowHeight = 240.0

        
        tableView.backgroundView = BackgroundView() // TODO: Move this out to a theme manager.
        tableView.separatorColor = Theme.Color.navBarColor
        
        // Position refresh control above background view
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.layer.zPosition = tableView.backgroundView!.layer.zPosition + 1
        
        // Make sure the idle screen timer is turned back to normal. Screen will time out.
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        // TODO: If there is only one site in the array, push to the detail controller right away. If a new or second one is added dismiss and return to table view.
        // TODO: Faking a data transfter date.
        // TODO: Need to update the table when data changes... also need to call updateTable if empty to show an empty row.
        //        NSNotificationCenter.defaultCenter().addObserverForName(DataUpdatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
        //            self.tableView.reloadData()
        //        }
        
    }
    
    func updateData(userInitiated: Bool = true){
        // Do not allow refreshing to happen if there is no data in the sites array.
        if sites.isEmpty == false {
            if refreshControl?.refreshing == false {
                refreshControl?.beginRefreshing()
                tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y-refreshControl!.frame.size.height), animated: true)
            }
            
            for (index,site) in sites.enumerate() {
                
                let getSites = GetSiteDataOperation(withSites: site) {
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
                    }
                }
                
                if userInitiated {
                    getSites.userIntent = .Initiated
                }
                
                operationQueue.addOperation(getSites)
            }
            //                rac_nightscouterFetchSiteConfigurationData(withSite: site)
            //                    .observeOn(UIScheduler())
            //                    .startWithNext { configuration in
            //                        var newSite = site
            //                        newSite.configuration = configuration
            //                        SitesDataSource.sharedInstance.updateSite(newSite)
            //                }
            //
            //                rac_nightscouterConnectToSocketSignal(withSite: site)
            //                    .observeOn(UIScheduler())
            //                    .map({ (items, event) -> Site in
            //                        var newSite = site
            //
            //                        newSite.parseJSONforSocketData(items)
            //                        SitesDataSource.sharedInstance.updateSite(newSite)
            //                        return newSite
            //
            //                    })
            //                    .startWithNext { (site) in
            //                        NSNotificationCenter.defaultCenter().postNotificationName(DataUpdatedNotification, object: nil)
            //                }
            
            //            }
        }
        
        defer {
            // No data in the sites array. Cancel the refreshing!
            refreshControl?.endRefreshing()
        }
    }
    
    func shouldIShowNewSiteForm() {
        // If the sites array is empty show a vesion of the form that does not allow escape.
        if sites.isEmpty{
            let vc = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIdentifier.FormViewController.rawValue) as! FormViewController
            self.parentViewController!.presentViewController(vc, animated: true, completion: { () -> Void in
                print("Finished presenting SiteFormViewController.")
                
            })
        }
    }
    
    // Attempt to handle an error.
    func presentAlertDialog(siteURL:NSURL, index: Int, error: NSError) {
        
        let alertController = UIAlertController(title: LocalizedString.uiAlertBadSiteTitle.localized, message: String(format: LocalizedString.uiAlertBadSiteMessage.localized, siteURL, error.localizedDescription), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: LocalizedString.generalCancelLabel.localized, style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let retryAction = UIAlertAction(title: LocalizedString.generalRetryLabel.localized, style: .Default) { (action) in
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let site = SitesDataSource.sharedInstance.sites[indexPath.row]
            //site.disabled = false
            SitesDataSource.sharedInstance.updateSite(site)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        alertController.addAction(retryAction)
        
        let editAction = UIAlertAction(title: LocalizedString.generalEditLabel.localized, style: .Default) { (action) in
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let tableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)
            self.accessoryIndexPath = indexPath
            self.performSegueWithIdentifier(SegueIdentifier.EditExisting.rawValue, sender:tableViewCell)
        }
        alertController.addAction(editAction)
        
        let removeAction = UIAlertAction(title: LocalizedString.tableViewCellRemove.localized, style: .Destructive) { (action) in
            self.tableView.beginUpdates()
            //            SitesDataSource.sharedInstance.removeSite(index)
            SitesDataSource.sharedInstance.deleteSite(self.sites[index])
            
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
        alertController.addAction(removeAction)
        
        alertController.view.tintColor = NightscouterAssetKit.darkNavColor
        
        // self.view.window?.tintColor = nil
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        self.presentViewController(alertController, animated: true) {
            // remove nsnotification observer?
            // ...
        }
    }
}
