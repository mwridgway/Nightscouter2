//
//  Array+Extensions.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/8/16.
//  Copyright © 2016 Peter Ina. All rights reserved.
//

import Foundation

public extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

public extension Array {
    func difference<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if !otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
    
    func intersection<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
}

extension Array where Element: Equatable {
    public mutating func insertOrUpdate(object: Generator.Element) -> Bool {
        if let index = self.indexOf(object) {
            self[index] = object
        } else {
            self.append(object)
        }
        
        return self.contains(object)
    }
    
    public mutating func appendUniqueObject(object: Generator.Element) {
        if contains(object) == false {
            append(object)
        }
    }
    
    public mutating func remove(object: Generator.Element) -> Bool {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
        
        return self.contains(object)
    }
}

extension Array where Element: Dateable {
    public mutating func sortByDate(orderDescending descending: Bool = true) {
        let compare: NSComparisonResult = descending ? .OrderedDescending : .OrderedAscending
        self = self.sort({ (d1, d2) -> Bool in
            d1.date.compare(d2.date) == compare
        })
    }
}
public func sortByDate<T: Dateable>(a: [T], orderDescending descending: Bool = true) -> [T] {
    let compare: NSComparisonResult = descending ? .OrderedDescending : .OrderedAscending
    return a.sort({ (d1, d2) -> Bool in
        d1.date.compare(d2.date) == compare
    })
}