//
//  AppConfiguration.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation
import KeychainAccess

// TODO: Locallize these strings and move them to centeral location so all view can have consistent placeholder text.
public struct PlaceHolderStrings {
    public static let displayName: String = "----"
    public static let urlName: String = "- --- ---"
    public static let sgv: String = "---"
    public static let date: String = "----"
    public static let delta: String = "- --/--"
    public static let deltaAltJ: String = "∆"
    public static let raw: String = "--- : ---"
    public static let battery: String = "--%"

    
    public static let defaultColor: DesiredColorState = .Default
}

public enum StoryboardIdentifier: String, RawRepresentable {
    case FormViewController, SitesTableViewController, SiteListPageViewController, SiteDetailViewController
    public static let allValues = [FormViewController, SitesTableViewController, SiteListPageViewController, SiteDetailViewController]
}

public class AppConfiguration {
    // MARK: Types

    public static var keychain: Keychain {
        return Keychain(service: "com.nothingonline.nightscouter")
    }
    
    private struct Defaults {
        static let firstLaunchKey = "AppConfiguration.Defaults.firstLaunchKey"
        static let storageOptionKey = "AppConfiguration.Defaults.storageOptionKey"
        static let storedUbiquityIdentityToken = "AppConfiguration.Defaults.storedUbiquityIdentityToken"
    }
    
    public struct Constant {
        public static let knownMilliseconds: Mills = 1168583640000
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
    
    public static let serverTimeDateFormatter: NSDateFormatter = {
        // Sample String: "2016-01-13T15:31:11.023Z"
        let formatString = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter
    }()
}