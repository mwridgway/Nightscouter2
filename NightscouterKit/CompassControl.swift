//
//  CompassView.swift
//  Nightscout Watch Face
//
//  Created by Peter Ina on 4/30/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import UIKit

@IBDesignable
public class CompassControl: UIView {
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(156, 196)
    }
    
    @IBInspectable
    public var sgvText:String = PlaceHolderStrings.sgv {
        didSet{
            setNeedsDisplay()
        }
    }

    @IBInspectable
    public var color: UIColor = DesiredColorState.Neutral.colorValue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var delta: String = PlaceHolderStrings.delta {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private var animationValue: CGFloat = 0
    private var angle: CGFloat = 0
    private var isUncomputable = false
    private var isDoubleUp = false
    private var isArrowVisible = false
    
    public var direction: Direction = .None {
        didSet {
            switch direction {
            case .None:
                configireDrawRect(isArrowVisible: false)
            case .DoubleUp:
                configireDrawRect(true)
            case .SingleUp:
                configireDrawRect()
            case .FortyFiveUp:
                configireDrawRect(angle:-45)
            case .Flat:
                configireDrawRect(angle:-90)
            case .FortyFiveDown:
                configireDrawRect(angle:-120)
            case .SingleDown:
                configireDrawRect(angle:-180)
            case .DoubleDown:
                configireDrawRect(true, angle: -180)
            case .NotComputable, .Not_Computable:
                configireDrawRect(isArrowVisible: false, isUncomputable: true)
            case .RateOutOfRange:
                configireDrawRect(isArrowVisible: false, isUncomputable: true, sgvText: direction.description)
            }
                setNeedsDisplay()

        }
    }
}

// MARK: - Lifecycle
public extension CompassControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()

        isAccessibilityElement = true

        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        
        NightscouterAssetKit.drawTextBlock(frame: rect, arrowTintColor: self.color, sgvText: self.sgvText, bg_delta: self.delta, textSizeForSgv: 39, textSizeForDelta: 12)
        
        if self.isUncomputable {
            NightscouterAssetKit.drawUncomputedCircle(frame: rect, arrowTintColor:self.color, isUncomputable: self.isUncomputable, computeAnimation: self.animationValue)
        } else {
            NightscouterAssetKit.drawWatchFaceOnly(frame: rect, arrowTintColor: self.color, angle: self.angle, isArrowVisible: self.isArrowVisible, doubleUp: self.isDoubleUp)
        }
        
        accessibilityHint = "Glucose Value of \(sgvText) with a delta of \(delta), with the following direction \(direction)"
    }

}

// MARK: - Methods
public extension CompassControl {
    private func configireDrawRect( isDoubleUp:Bool = false, isArrowVisible:Bool = true, isUncomputable:Bool = false, angle:CGFloat?=0, sgvText:String?=nil ){
        self.isDoubleUp = isDoubleUp
        self.isArrowVisible = isArrowVisible
        self.isUncomputable = isUncomputable
        
        self.angle = angle!
        if (sgvText != nil) {
            self.sgvText = sgvText!
        }
        
    }
    
    public func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public extension CompassControl {
    public func configure(withDataSource dataSource: CompassViewDataSource, delegate: CompassViewDelegate?) {
        direction = dataSource.direction
        delta = dataSource.detailText
        sgvText = dataSource.text
        color = delegate?.desiredColor.colorValue ?? DesiredColorState.Neutral.colorValue
        shouldLookStale(look: dataSource.lookStale)
    }
    
    public func shouldLookStale(look stale: Bool = true) {
        if stale {
            let compass = CompassControl()
            self.alpha = 0.5
            self.color = compass.color
            self.sgvText = compass.sgvText
            self.direction = compass.direction
            self.delta = compass.delta
        } else {
            self.alpha = 1.0
        }
    }
    
}