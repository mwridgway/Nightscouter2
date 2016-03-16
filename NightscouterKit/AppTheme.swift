//
//  AppTheme.swift
//  Nightscouter
//
//  Created by Peter Ina on 8/4/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import UIKit

import DateTools

public struct Theme {
    public struct Color {
        public static let windowTintColor =  NightscouterAssetKit.predefinedNeutralColor
        public static let headerTextColor = UIColor(white: 1.0, alpha: 0.5)
        public static let labelTextColor = UIColor.whiteColor()
        public static let navBarColor: UIColor = NightscouterAssetKit.darkNavColor
        public static let navBarTextColor: UIColor = UIColor.whiteColor()
    }
    
    public struct Font {
        public static let navBarTitleFont = UIFont(name: "HelveticaNeue-Thin", size: 20.0)
    }
    
    public static func customizeAppAppearance(sharedApplication application:UIApplication, forWindow window: UIWindow?) {
        application.statusBarStyle = .LightContent
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
}