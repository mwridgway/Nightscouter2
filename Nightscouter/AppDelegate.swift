//
//  AppDelegate.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: String?
    
    override init() {
        super.init()
        WatchSessionManager.sharedManager.startSession()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Theme.customizeAppAppearance(sharedApplication: UIApplication.sharedApplication(), forWindow: window)
        
        // Register for intial settings.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        registerInitialSettings(userDefaults)
        
        // Register for settings changes as store might have changed
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("userDefaultsDidChange:"),
            name: NSUserDefaultsDidChangeNotification,
            object: nil)
        
        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem.type
        }
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Save data.
        SitesDataSource.sharedInstance.saveSitesToDefaults()
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
            print("Recieved URL: \(url) with options: \(options)")
        #endif
        
        // If the incoming scheme is not contained within the array of supported schemes return false.
        guard let schemes = LinkBuilder.supportedSchemes where schemes.contains(url.scheme) else { return false }
        
        // We now have an acceptable scheme. Pass the URL to the deep linking handler.
        deepLinkToURL(url)
        
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        print(shortcutItem)
        
        guard let type = CommonUseCasesForShortcuts(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        
        switch type {
        case .AddNew:
            let url = type.linkForUseCase()
            deepLinkToURL(url)
        case .ShowDetail:
            let siteIndex = shortcutItem.userInfo!["siteIndex"] as! Int
            SitesDataSource.sharedInstance.lastViewedSiteIndex = siteIndex
            
            #if DEDBUG
                println("User tapped on notification for site: \(site) at index \(siteIndex) with UUID: \(uuid)")
            #endif
            
            let url = type.linkForUseCase()
            
            deepLinkToURL(url)
        default:
            completionHandler(false)
        }
        
        completionHandler(true)
    }
    
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // TODO: Background fetch new data and update watch.
        
        completionHandler(.NewData)
    }
}

extension AppDelegate {
    
    func deepLinkToURL(url: NSURL) {
        // Maybe this can be expanded to handle icomming messages from remote or local notifications.
        guard let pathComponents = url.pathComponents else {
            return
        }
        
        if let queryItems = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems {
            #if DEBUG
                print("queryItems: \(queryItems)") // Not handling queries at that moment, but might want to.
            #endif
        }
        
        guard let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window else {
            return
        }
        
        if let navController = window.rootViewController as? UINavigationController { // Get the root view controller's navigation controller.
            
            navController.popToRootViewControllerAnimated(false) // Return to root viewcontroller without animation.
            navController.dismissViewControllerAnimated(false, completion: { () -> Void in
                //
            })
            let storyboard = window
                .rootViewController?.storyboard // Grab the storyboard from the rootview.
            var viewControllers = navController.viewControllers // Grab all the current view controllers in the stack.
            
            for pathComponent in pathComponents { // iterate through all the path components. Currently the app only has one level of deep linking.
                
                // Attempt to create a storyboard identifier out of the string.
                guard let storyboardIdentifier = StoryboardIdentifier(rawValue: pathComponent) else {
                    continue
                }
                
                let linkIsAllowed = StoryboardIdentifier.deepLinkable.contains(storyboardIdentifier) // Check to see if this is an allowed viewcontroller.
                
                if linkIsAllowed {
                    let newViewController = storyboard!.instantiateViewControllerWithIdentifier(storyboardIdentifier.rawValue)
                    
                    switch (storyboardIdentifier) {
                    case .SiteListPageViewController:
                        viewControllers.append(newViewController) // Create the view controller and append it to the navigation view controller stack
                    case .FormViewNavigationController, .FormViewController:
                        navController.presentViewController(newViewController, animated: false, completion: { () -> Void in
                            // ...
                        })
                    default:
                        viewControllers.append(newViewController) // Create the view controller and append it to the navigation view controller stack
                    }
                }
            }
            navController.viewControllers = viewControllers // Apply the updated list of view controller to the current navigation controller.
        }
        
    }
    
    
    
    
    // MARK: Notifications
    
    func userDefaultsDidChange(notification: NSNotification) {
        if let userDefaults = notification.object as? NSUserDefaults {
            // archiveStoreIfLocal()
            // store = storeForUserDefaults(userDefaults)
            // tabBarController.viewControllers = tabViewControllersForStore(store)
            
            print("Defaults Changed")
            //            let userInfo = WatchSessionManager.sharedManager.transferUserInfo(userDefaults.dictionaryRepresentation())
            //            print(userInfo)
            let compInfo = WatchSessionManager.sharedManager.transferCurrentComplicationUserInfo(userDefaults.dictionaryRepresentation())
            print(compInfo)
        }
    }
    
    private func registerInitialSettings(userDefaults: NSUserDefaults) {
        
    }
    
    func setupNotificationSettings() {
        print(">>> Entering \(__FUNCTION__) <<<")
        // Specify the notification types.
        let notificationTypes: UIUserNotificationType = [.Alert, .Sound, .Badge]
        
        // Register the notification settings.
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        
        // TODO: Enabled remote notifications... need to get a server running.
        // UIApplication.sharedApplication().registerForRemoteNotifications()
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    
    // TODO: Datasource needs to produce a signal, notification or callback so that the delegate can request premissions.
    
    // AppDataManagerNotificationDidChange Handler
    func dataManagerDidChange(notification: NSNotification) {
        
        let sites = SitesDataSource.sharedInstance.sites
        
        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == .None || !sites.isEmpty {
            setupNotificationSettings()
        }
        
        UIApplication.sharedApplication().shortcutItems = nil
        
        let useCase = CommonUseCasesForShortcuts.ShowDetail.applicationShortcutItemType
        
        for (index, site) in sites.enumerate() {
            
            let mvm = site.generateSummaryModelViewModel()
            
            UIApplication.sharedApplication().shortcutItems?.append(UIApplicationShortcutItem(type: useCase, localizedTitle: mvm.nameLabel, localizedSubtitle: mvm.urlLabel, icon: nil, userInfo: ["uuid": site.uuid.UUIDString, "siteIndex": index]))
        }
    }
    
}

