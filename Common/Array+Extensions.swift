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