//
//  NSDate-Extensions.swift
//  Nightscouter
//
//  Created by Peter Ina on 2/2/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation


public extension NSDate {
    func timeAgoSinceNow() -> String {
        return NSCalendar.autoupdatingCurrentCalendar().stringRepresentationOfElapsedTimeSinceNow(self)
    }
}

//MARK: OPERATIONS WITH DATES (==,!=,<,>,<=,>=)

extension NSDate : Comparable {}

public func == (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedSame)
}

public func != (left: NSDate, right: NSDate) -> Bool {
    return !(left == right)
}

public func < (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedAscending)
}

public func > (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedDescending)
}

public func <= (left: NSDate, right: NSDate) -> Bool {
    return !(left > right)
}

public func >= (left: NSDate, right: NSDate) -> Bool {
    return !(left < right)
}

//MARK: ARITHMETIC OPERATIONS WITH DATES (-,-=,+,+=)

public func - (left : NSDate, right: NSTimeInterval) -> NSDate {
    return left.dateByAddingTimeInterval(-right)
}

public func -= (inout left: NSDate, right: NSTimeInterval) {
    left = left.dateByAddingTimeInterval(-right)
}

public func + (left: NSDate, right: NSTimeInterval) -> NSDate {
    return left.dateByAddingTimeInterval(right)
}

public func += (inout left: NSDate, right: NSTimeInterval) {
    left = left.dateByAddingTimeInterval(right)
}
