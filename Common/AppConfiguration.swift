//
//  AppConfiguration.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import KeychainAccess


public let DataUpdatedNotification: String = "com.nothingonline.nightscouter.dataUpdated"

public typealias ArrayOfDictionaries = [[String: AnyObject]]


// TODO: Locallize these strings and move them to centeral location so all view can have consistent placeholder text.
public struct PlaceHolderStrings {
    public static let displayName: String = "----"
    public static let urlName: String = "- --- ---"
    public static let sgv: String = "---"
    public static let date: String = "----"
    public static let delta: String = "- --/--"
    public static let deltaAltJ: String = "∆"
    public static let raw: String = "---"
    public static let battery: String = "--%"
    public static let appName: String = LocalizedString.nightscoutTitleString.localized
    public static let defaultColor: DesiredColorState = .Default
}


public struct LinkBuilder {
    public enum LinkType: String {
        case Link = "link"
    }
    
    public static var supportedSchemes: [String]? {
        if let info = NSBundle.mainBundle().infoDictionary {
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
    
    public static func buildLink(forType type: LinkType = .Link, withViewController viewController: StoryboardIdentifier) -> NSURL {
        
        // should probably do somethning with the supportedSchemes here...
        return NSURL(string: "nightscouter://\(type.rawValue)/\(viewController.rawValue)")!
    }
}


public enum CommonUseCasesForShortcuts: String {
    case ShowDetail, AddNew, AddNewWhenEmpty, ShowList
    
    public func linkForUseCase() -> NSURL {
        switch self {
        case .ShowDetail: return LinkBuilder.buildLink(forType: .Link, withViewController: .SiteListPageViewController)
        case .ShowList: return LinkBuilder.buildLink(forType: .Link, withViewController: .SitesTableViewController)
        case .AddNewWhenEmpty: return LinkBuilder.buildLink(forType: .Link, withViewController: .FormViewController)
        case .AddNew: return LinkBuilder.buildLink(forType: .Link, withViewController: .FormViewNavigationController)
        }
    }

    public var applicationShortcutItemType: String {
        return AppConfiguration.applicationName + "." + self.rawValue
    }
}

public enum StoryboardIdentifier: String, RawRepresentable {
    case FormViewController, FormViewNavigationController, SitesTableViewController, SiteListPageViewController, SiteDetailViewController, SiteSettingsNavigationViewController
    public static let allValues = [FormViewController, FormViewNavigationController, SitesTableViewController, SiteListPageViewController, SiteDetailViewController, SiteSettingsNavigationViewController]
    public static let deepLinkable = [FormViewNavigationController, FormViewController, SiteListPageViewController, SitesTableViewController]
}

public class AppConfiguration {
    // MARK: Types
    
    public static let applicationName = "com.nothingonline.nightscouter"
    public static let sharedApplicationGroupSuiteName: String = "group.com.nothingonline.nightscouter"

    public static var keychain: Keychain {
        return Keychain(service: applicationName).synchronizable(true)
    }
    
    private struct Defaults {
        static let firstLaunchKey = "AppConfiguration.Defaults.firstLaunchKey"
        static let storageOptionKey = "AppConfiguration.Defaults.storageOptionKey"
        static let storedUbiquityIdentityToken = "AppConfiguration.Defaults.storedUbiquityIdentityToken"
    }
    
    public struct Constant {
        public static let knownMilliseconds: Mills = 1268197200000
        public static let knownMgdl: MgdlValue = 100
    }
    
    /**
     Formatter used to display the date and time that data was last updated.
     Example output:
     ```
     Jan 12, 2007, 11:11:46 AM
     ```
     */
    public static let lastUpdatedDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()
    
    public static let lastUpdatedFromPhoneDateFormatter: NSDateFormatter = {
        // Create and use a formatter.
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        return dateFormatter
    }()
    
    public static let serverTimeDateFormatter: NSDateFormatter = {
        // Sample String: "2016-01-13T15:31:11.023Z"
        let formatString = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter
    }()
}