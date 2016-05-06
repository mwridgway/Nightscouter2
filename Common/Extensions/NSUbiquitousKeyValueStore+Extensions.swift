//
//  NSUbiquitousKeyValueStore+Extensions.swift
//  Nightscouter
//
//  Created by Peter Ina on 3/1/16.
//  Copyright © 2016 Peter Ina. All rights reserved.
//

import Foundation

extension NSUbiquitousKeyValueStore {
    public func resetStorage() -> Bool {
        for key in self.dictionaryRepresentation.keys
        {
            self.removeObjectForKey(key)
        }
        
        // Sync back to iCloud
        return self.synchronize()
    }
}


extension Dictionary {
    /**
     It's not uncommon to want to turn a sequence of values into a dictionary,
     where each value is keyed by some unique identifier. This initializer will
     do that.
     
     - parameter sequence: The sequence to be iterated
     
     - parameter keyer: The closure that will be executed for each element in
     the `sequence`. The return value of this closure, if there is one, will
     be used as the key for the value in the `Dictionary`. If the closure
     returns `nil`, then the value will be omitted from the `Dictionary`.
     */
    public init<Sequence: SequenceType where Sequence.Generator.Element == Value>(sequence: Sequence, @noescape keyMapper: Value -> Key?) {
        self.init()
        
        for item in sequence {
            if let key = keyMapper(item) {
                self[key] = item
            }
        }
    }
}