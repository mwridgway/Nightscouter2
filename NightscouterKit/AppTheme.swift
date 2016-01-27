//
//  AppTheme.swift
//  Nightscouter
//
//  Created by Peter Ina on 8/4/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import UIKit

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
}