//
//  SitesTableViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/13/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit

class SitesTableViewController: UITableViewController, SitesDataSourceProvider, SegueHandlerType {
    
    struct CellIdentifier {
        static let SiteTableViewStyleLarge = "siteCellLarge"
    }
    
    enum SegueIdentifier: String {
        case EditExisting, ShowDetail, AddNew, AddNewWhenEmpty, LaunchLabs, ShowPageView, UnwindToSiteList
    }
    
    var sites: [Site] = [] {
        didSet{
            self.configureView()
            
        }
    }
    //        {
    //        return SitesDataSource.sharedInstance.sites
    //    }
    
    
    var milliseconds: Double = 0 {
        didSet{
            let str = String(stringInterpolation:LocalizedString.lastUpdatedDateLabel.localized, AppConfiguration.lastUpdatedDateFormatter.stringFromDate(date))
            self.refreshControl?.attributedTitle = NSAttributedString(string:str, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        }
    }
    
    
    /**
     Holds the indexPath of an accessory that was tapped.
     Used for triggering a transition into edit mode.
     */
    var accessoryIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Common setup.
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let site = SitesDataSource.sharedInstance.sites.first
       
        // TODO: REMOVE
        let socketClient = NightscoutSocketIOClient(url: (site?.url)!, apiSecret: site?.apiSecret)
        socketClient.mapToJsonValues().observeNext { data in
            if let siteIndex = self.sites.indexOf(data) {
                self.sites[siteIndex] = data
                let indexPath = NSIndexPath(forRow: siteIndex, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                self.sites.append(data)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)

                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        
        
        // Check if we should display a form.
        // shouldIShowNewSiteForm()
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
        
        let model = SiteSummaryModelViewModel(withSite: sites[indexPath.row])
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
            // AppDataManageriOS.sharedInstance.deleteSiteAtIndex(indexPath.row)
            
            // Delete the row from the data source
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // If the site array is empty show add form.
            shouldIShowNewSiteForm()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // Pull the site that was moved from the data source at its current (fromIndexPath) location.
        // let site = sites[fromIndexPath.row]
        
        // Remove the site from the data source from its orginal (fromIndexPath) location.
        // AppDataManageriOS.sharedInstance.deleteSiteAtIndex(fromIndexPath.row)
        
        // Insert the site into the data source at its new (toIndexPath) location.
        // AppDataManageriOS.sharedInstance.addSite(site, index: toIndexPath.row)
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
                let indexPath = tableView.indexPathForCell(selectedSiteCell)!
                // AppDataManageriOS.sharedInstance.currentSiteIndex = indexPath.row
            }
            
            if let incomingSite = sender as? Site{
                if let indexOfSite = sites.indexOf(incomingSite) {
                    // AppDataManageriOS.sharedInstance.currentSiteIndex = indexOfSite
                }
            }
            
        default:
            #if DEBUG
                print("Unhandled segue idendifier: \(segue.identifier)", terminator: "")
            #endif
        }
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func refreshTable(sender: UIRefreshControl) {
        updateData()
    }
    
    @IBAction func unwindToSiteList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as? FormViewController, site = sourceViewController.site {
            
            // This segue is triggered when we "save" or "next" out of the url form.
            if let selectedIndexPath = accessoryIndexPath {
                // Update an existing site.
                // AppDataManageriOS.sharedInstance.updateSite(site)
                
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                accessoryIndexPath = nil
            } else {
                // Add a new site.
                editing = false
                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                // AppDataManageriOS.sharedInstance.addSite(site, index: newIndexPath.row)
                SitesDataSource.sharedInstance.sites.insert(site, atIndex: newIndexPath.row)
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
        tableView.rowHeight = 240
        tableView.backgroundView = BackgroundView() // TODO: Move this out to a theme manager.
        tableView.separatorColor = NightscouterAssetKit.darkNavColor
        
        // Position refresh control above background view
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.layer.zPosition = tableView.backgroundView!.layer.zPosition + 1
        
        // Make sure the idle screen timer is turned back to normal. Screen will time out.
        //AppDataManageriOS.sharedInstance.shouldDisableIdleTimer = false
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func updateData(){
        // Do not allow refreshing to happen if there is no data in the sites array.
        if sites.isEmpty == false {
            if refreshControl?.refreshing == false {
                refreshControl?.beginRefreshing()
                tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y-refreshControl!.frame.size.height), animated: true)
            }
            // for (index, site) in sites.enumerate() {
            //  refreshDataFor(site, index: index)
            // }
            // refreshControl?.endRefreshing()
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
            //let site = AppDataManageriOS.sharedInstance.sites[indexPath.row]
            //site.disabled = false
            //AppDataManageriOS.sharedInstance.updateSite(site)
            
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
            //AppDataManageriOS.sharedInstance.deleteSiteAtIndex(index)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
        alertController.addAction(removeAction)
        
        alertController.view.tintColor = NightscouterAssetKit.darkNavColor
        
        self.view.window?.tintColor = nil
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        self.presentViewController(alertController, animated: true) {
            // remove nsnotification observer?
            // ...
        }
    }
    
    
}
