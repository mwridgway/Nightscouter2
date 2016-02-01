//
//  Array-Extensions.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/29/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    public mutating func insertOrUpdate(object: Generator.Element) {
        if let index = self.indexOf(object) {
            self[index] = object
        } else {
            self.append(object)
        }
        
    }
    
    public mutating func appendUniqueObject(object: Generator.Element) {
        if contains(object) == false {
            append(object)
        }
    }
}

extension Array where Element: Dateable {
    public mutating func sortByDate(orderDescending descending: Bool = true) {
        let compare: NSComparisonResult = descending ? .OrderedDescending :.OrderedAscending
        self = self.sort({ (d1, d2) -> Bool in
            d1.date.compare(d2.date) == compare
        })
    }
}
public func sortByDate<T: Dateable>(a: [T], orderDescending descending: Bool = true) -> [T] {
    let compare: NSComparisonResult = descending ? .OrderedDescending :.OrderedAscending
    return a.sort({ (d1, d2) -> Bool in
        d1.date.compare(d2.date) == compare
    })
}