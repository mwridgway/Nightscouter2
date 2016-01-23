//
//  Extensions.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit

extension Array {
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