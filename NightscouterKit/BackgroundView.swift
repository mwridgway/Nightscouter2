//
//  TableViewBackgroundView.swift
//  Nightscouter
//
//  Created by Peter Ina on 7/17/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import UIKit

//@IBDesignable
public class BackgroundView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.

    public override func drawRect(rect: CGRect) {
        if let backgroundColor = backgroundColor {
            if !(backgroundColor == UIColor.clearColor()) {
                NightscouterAssetKit.drawTableViewBackgroundView(backgroundFrame: rect)
            }
        } else {
            NightscouterAssetKit.drawTableViewBackgroundView(backgroundFrame: rect)
        }
    }
    
}