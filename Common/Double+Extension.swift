//
//  ApplicationExtensions.swift
//  Nightscout
//
//  Created by Peter Ina on 5/18/15.
//  Copyright (c) 2015 Peter Ina. All rights reserved.
//

import Foundation

public extension Range
{
    public var randomInt: Int
        {
        get
        {
            var offset = 0
            
            if (startIndex as! Int) < 0   // allow negative ranges
            {
                offset = abs(startIndex as! Int)
            }
            
            let mini = UInt32(startIndex as! Int + offset)
            let maxi = UInt32(endIndex as! Int + offset)
            
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
}

public extension MgdlValue {
    public var toMmol: Double {
        get{
            return (self / 18)
        }
    }
    
    public var toMgdl: Double {
        get{
            return floor(self * 18)
        }
    }
    
    internal var mgdlFormatter: NSNumberFormatter {
        let numberFormat = NSNumberFormatter()
        numberFormat.numberStyle = .NoStyle
        
        return numberFormat
    }
    
    public var formattedForMgdl: String {
        if let reserved  = ReservedValues(mgdl: self) {
            return reserved.description
        }
        
        return self.mgdlFormatter.stringFromNumber(self)!
    }

    internal var mmolFormatter: NSNumberFormatter {
        let numberFormat = NSNumberFormatter()
        numberFormat.numberStyle = .DecimalStyle
        numberFormat.minimumFractionDigits = 1
        numberFormat.maximumFractionDigits = 1
        numberFormat.secondaryGroupingSize = 1

        return numberFormat
    }
    
    public var formattedForMmol: String {
        
        if let reserved  = ReservedValues(mgdl: self) {
            return reserved.description
        }

        return self.mmolFormatter.stringFromNumber(self.toMmol)!
    }
}

public extension Double {
    internal var bgDeltaFormatter: NSNumberFormatter {
        let numberFormat =  NSNumberFormatter()
        numberFormat.numberStyle = .DecimalStyle
        numberFormat.positivePrefix = numberFormat.plusSign
        numberFormat.negativePrefix = numberFormat.minusSign
        numberFormat.minimumFractionDigits = 1
        numberFormat.maximumFractionDigits = 1
        numberFormat.secondaryGroupingSize = 1
        
        return numberFormat
    }
    
    public var formattedForBGDelta: String {
        return self.bgDeltaFormatter.stringFromNumber(self)!
    }
}

public extension Double {
    var isInteger: Bool {
        return rint(self) == self
    }
}

public extension Double {
    public func millisecondsToSecondsTimeInterval() -> NSTimeInterval {
        return round(self/1000)
    }
    
    public var inThePast: NSTimeInterval {
        return -self
    }
    
    public func toDateUsingMilliseconds() -> NSDate {
        let date = NSDate(timeIntervalSince1970:millisecondsToSecondsTimeInterval())
        return date
    }
    
}

extension NSTimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d.%03d", minute , second, millisecond  )
    }
    var minute: Double {
        return (self/60.0)%60
    }
    var second: Double {
        return self % 60
    }
    var millisecond: Double {
        return self*1000
    }
}

extension Int {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}