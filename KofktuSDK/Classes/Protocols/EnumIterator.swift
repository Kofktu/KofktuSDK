//
//  EnumIterator.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 4. 6..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation

public protocol EnumIterator: Hashable {}
public extension EnumIterator {
    static var iterator: AnyIterator<Self> {
        var raw = 0
        return AnyIterator.init({
            let next = withUnsafeBytes(of: &raw, {
                $0.load(as: Self.self)
            })
            guard next.hashValue == raw else {
                return nil
            }
            raw += 1
            return next
        })
    }
    
    static var all: [Self] {
        return Array(iterator)
    }
}
