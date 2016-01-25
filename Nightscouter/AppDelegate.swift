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
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        customizeAppAppearance()

        // Register for intial settings.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        registerInitialSettings(userDefaults)
        
        // Register for settings changes as store might have changed
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("userDefaultsDidChange:"),
            name: NSUserDefaultsDidChangeNotification,
            object: nil)

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Save data.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
            print("Recieved URL: \(url) with options: \(options)")
        #endif
        let schemes = supportedSchemes!
        if (!schemes.contains((url.scheme))) { // If the incoming scheme is not contained within the array of supported schemes return false.
            return false
        }
        
        // We now have an acceptable scheme. Pass the URL to the deep linking handler.
        deepLinkToURL(url)
        
        return true
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
                
                let linkIsAllowed = StoryboardIdentifier.allValues.contains(storyboardIdentifier) // Check to see if this is an allowed viewcontroller.
                
                if linkIsAllowed {
                    let newViewController = storyboard!.instantiateViewControllerWithIdentifier(storyboardIdentifier.rawValue)
                    
                    switch (storyboardIdentifier) {
                    case .SiteListPageViewController:
                        viewControllers.append(newViewController) // Create the view controller and append it to the navigation view controller stack
                    case .FormViewController:
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
    
    var supportedSchemes: [String]? {
        if let info = NSBundle.mainBundle().infoDictionary as [String : AnyObject]? {
            var schemes = [String]() // Create an empty array we can later set append available schemes.
            if let bundleURLTypes = info["CFBundleURLTypes"] as? [AnyObject] {
                for (index, _) in bundleURLTypes.enumerate() {
                    if let urlTypeDictionary = bundleURLTypes[index] as? [String : AnyObject] {
                        if let urlScheme = urlTypeDictionary["CFBundleURLSchemes"] as? [String] {
                            schemes += urlScheme // We've found the supported schemes appending to the array.
                            return schemes
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func customizeAppAppearance() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // Change the font and size of nav bar text.
        window?.tintColor = Theme.Color.windowTintColor

        if let navBarFont = Theme.Font.navBarTitleFont {
            
            let navBarColor: UIColor = Theme.Color.navBarColor
            UINavigationBar.appearance().barTintColor = navBarColor
            UINavigationBar.appearance().tintColor = Theme.Color.windowTintColor

            let navBarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: Theme.Color.navBarTextColor,
                NSFontAttributeName: navBarFont
            ]
            
            UINavigationBar.appearance().titleTextAttributes = navBarAttributesDictionary
        }
    }

    
    // MARK: Notifications
    
    func userDefaultsDidChange(notification: NSNotification) {
        if let _ = notification.object as? NSUserDefaults {
            // archiveStoreIfLocal()
            // store = storeForUserDefaults(userDefaults)
            // tabBarController.viewControllers = tabViewControllersForStore(store)
        }
    }
 
    private func registerInitialSettings(userDefaults: NSUserDefaults) {
    }

}

