//
//  Atomic.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Atomic<T> {
    private var wrapped: T
    private let lock = NSLock()

    public init(wrappedValue value: T) {
        self.wrapped = value
    }

    public var wrappedValue: T {
      get { getValue() }
      set { setValue(newValue) }
    }

    public func getValue() -> T {
        lock.lock(); defer { lock.unlock() }
        return wrapped
    }

    public mutating func setValue(_ value: T) {
        lock.lock(); defer { lock.unlock() }
        wrapped = value
    }
}
