//
//  ViewController.swift
//  Nightscout
//
//  Created by Peter Ina on 5/14/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import UIKit
import NightscouterKit
import SafariServices

class SiteDetailViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak private var siteCompassControl: CompassControl?
    @IBOutlet weak private var siteLastReadingHeader: UILabel?
    @IBOutlet weak private var siteLastReadingLabel: UILabel?
    @IBOutlet weak private var siteBatteryHeader: UILabel?
    @IBOutlet weak private var siteBatteryLabel: UILabel?
    @IBOutlet weak private var siteRawHeader: UILabel?
    @IBOutlet weak private var siteRawLabel: UILabel?
    @IBOutlet weak private var siteNameLabel: UILabel?
    @IBOutlet weak private var siteWebView: UIWebView?
    @IBOutlet weak private var siteActivityView: UIActivityIndicatorView?
    
    // MARK: Properties
    var site: Site? {
        didSet {
            guard let site = site else { return }
            self.configureView(withSite: site)
            //            let socket = NightscoutSocketIOClient(site: site)
            //
            //            socket.fetchConfigurationData().startWithNext { racSite in
            //                if let racSite = racSite {
            //                    SitesDataSource.sharedInstance.updateSite(racSite)
            //
            //                }
            //            }
            //            socket.fetchSocketData().observeNext { racSite in
            //                SitesDataSource.sharedInstance.updateSite(racSite)
            //                self.configureView(withSite: racSite)
            //            }
        }
    }
    //var nsApi: NightscoutAPIClient?
    var data = [AnyObject]() {
        didSet{
            loadWebView()
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove any uneeded decorations from this view if contained within a UI page view controller
        if let _ = parentViewController as? UIPageViewController {
            // println("contained in UIPageViewController")
            self.view.backgroundColor = UIColor.clearColor()
            self.siteNameLabel?.removeFromSuperview()
        }
        
        configureView(withSite: self.site ?? Site())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //nsApi?.task?.cancel()
        data.removeAll()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.siteWebView?.reload()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension SiteDetailViewController{
    @IBAction func unwindToSiteDetail(segue:UIStoryboardSegue) {
        // print(">>> Entering \(#function) <<<")
        // print("\(segue)")
    }
    @IBAction func launchSiteSettings(sender: UIBarButtonItem) {
        presentSettings(sender)
    }
}

// MARK: WebKit WebView Delegates
extension SiteDetailViewController {
    func webViewDidFinishLoad(webView: UIWebView) {
        // print(">>> Entering \(#function) <<<")
        let updateData = "updateData(\(self.data))"
        
        if let configuration = site?.configuration {
            let updateUnits = "updateUnits(\(configuration.displayUnits.hashValue))"
            webView.stringByEvaluatingJavaScriptFromString(updateUnits)
        }
        webView.stringByEvaluatingJavaScriptFromString(updateData)
        webView.hidden = false
        siteActivityView?.stopAnimating()
    }
    
}

extension SiteDetailViewController {
    
    func configureView(withSite site: Site) {
        
        UIApplication.sharedApplication().idleTimerDisabled = site.overrideScreenLock
        
        let dataSource = site.generateSummaryModelViewModel()
        siteLastReadingLabel?.text = dataSource.lastReadingDate.timeAgoSinceNow()
        siteLastReadingLabel?.textColor = dataSource.lastReadingColor
        
        siteBatteryHeader?.hidden = dataSource.batteryHidden
        siteBatteryLabel?.hidden = dataSource.batteryHidden
        siteBatteryLabel?.text = dataSource.batteryLabel
        siteBatteryLabel?.textColor = dataSource.batteryColor
        
        siteRawLabel?.hidden = dataSource.rawHidden
        siteRawHeader?.hidden = dataSource.rawHidden
        
        siteRawLabel?.text = dataSource.rawFormatedLabel
        siteRawLabel?.textColor = dataSource.rawColor
        
        siteNameLabel?.text = dataSource.nameLabel
        siteCompassControl?.configure(withDataSource: dataSource, delegate: dataSource)
        
        self.updateTitles(dataSource.nameLabel)
        
        data = site.sgvs.map{ $0.jsonForChart }
        
    }
    
    func updateTitles(title: String) {
        self.navigationItem.title = title
        self.navigationController?.navigationItem.title = title
        self.siteNameLabel?.text = title
    }
    
    func loadWebView () {
        self.siteWebView?.delegate = self
        self.siteWebView?.scrollView.bounces = false
        self.siteWebView?.scrollView.scrollEnabled = false
        
        let filePath = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "html")
        let defaultDBPath = "\(NSBundle.mainBundle().resourcePath)\\html"
        
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(filePath!)
        if !fileExists {
            do {
                try NSFileManager.defaultManager().copyItemAtPath(defaultDBPath, toPath: filePath!)
            } catch _ {
            }
        }
        let request = NSURLRequest(URL: NSURL.fileURLWithPath(filePath!))
        self.siteWebView?.loadRequest(request)
    }
    
    func updateScreenOverride(shouldOverride: Bool) {
        
        self.site?.overrideScreenLock = shouldOverride
        SitesDataSource.sharedInstance.updateSite(self.site!)
        UIApplication.sharedApplication().idleTimerDisabled = site?.overrideScreenLock ?? false
        
        #if DEBUG
            print("{site.overrideScreenLock:\(site?.overrideScreenLock), AppDataManageriOS.shouldDisableIdleTimer:\(AppDataManageriOS.sharedInstance.shouldDisableIdleTimer), UIApplication.idleTimerDisabled:\(UIApplication.sharedApplication().idleTimerDisabled)}")
        #endif
    }
    
    func presentSettings(sender: UIBarButtonItem) {
        
        guard let alertController = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIdentifier.SiteSettingsNavigationViewController.rawValue) as? UINavigationController else {
            return
        }
        
        if let vc = alertController.viewControllers.first as? SiteSettingsTableViewController {
            vc.delegate = self
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.presentViewController(alertController, animated: true) {
            #if DEBUG
                print("presentViewController: \(alertController.debugDescription)")
            #endif
        }
    }
    
}

extension SiteDetailViewController: SiteSettingsDelegate {
    
    var settings: [SettingsModelViewModel] {
        
        var tempSettings: [SettingsModelViewModel] = []
        if let site = site {
            // FIXME: Add primary site conformance
            
            // let defaultSite = (site.uuid == SitesDataSource.sharedInstance.primarySiteUUID)
            
            let defaultSite = site == SitesDataSource.sharedInstance.lastViewedSite// (site.uuid == SitesDataSource.sharedInstance.primarySiteUUID)
            
            tempSettings.append(SettingsModelViewModel(title: LocalizedString.settingsPreventLocking.localized, intent: SettingIntent.PreventLocking , subTitle: nil, switchOn: site.overrideScreenLock))
            tempSettings.append(SettingsModelViewModel(title: LocalizedString.settingsDefaultSite.localized, intent: SettingIntent.SetDefault , subTitle: LocalizedString.settingsDefaultSiteSubTitle.localized, switchOn: defaultSite , cellIdentifier: .cellSubtitle))
            tempSettings.append(SettingsModelViewModel(title: LocalizedString.settingsEditSite.localized, intent: SettingIntent.Edit, subTitle: LocalizedString.settingsEditSiteSubTitle.localized, cellIdentifier: .cellBasicDisclosure))
            tempSettings.append(SettingsModelViewModel(title: LocalizedString.settingsGoToWeb.localized, intent: SettingIntent.GoToSafari, cellIdentifier: .cellBasic))
        }
        return tempSettings
    }
    
    
    func settingDidChange(setting: SettingsModelViewModel, atIndexPath: NSIndexPath, inViewController: SiteSettingsTableViewController) {
        
        switch setting.intent {
        case .PreventLocking:
            self.updateScreenOverride(setting.switchOn ?? false)
        case .SetDefault:
            if let boolSetting = setting.switchOn where boolSetting == true {
                
                // FIXME: Add primary site conformance
                //                SitesDataSource.sharedInstance.primarySiteUUID = site?.uuid
                SitesDataSource.sharedInstance.primarySite = site
            } else {
                //                SitesDataSource.sharedInstance.primarySiteUUID = nil
                SitesDataSource.sharedInstance.primarySite = nil
            }
        case .Edit:
            print("Edit")
            inViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                let formViewController = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIdentifier.FormViewController.rawValue) as! FormViewController
                
                formViewController.site = self.site!
                
                self.navigationController?.pushViewController(formViewController, animated: true)
                
            })
        case .GoToSafari:
            inViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                let svc = SFSafariViewController(URL: self.site!.url)
                self.presentViewController(svc, animated: true, completion: nil)
            })
        }
    }
}
