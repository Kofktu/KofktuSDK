//
//  LateInit.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

@propertyWrapper
public struct LateInit<T> {
    private var value: T?
    
    public init() {
        value = nil
    }
    
    public var wrappedValue: T {
        get {
            guard let value = value else {
                fatalError("Trying to access LateInit.value before setting it.")
            }
            return value
        }
        set { value = newValue }
    }
}

@propertyWrapper
public struct LazyInit<T> {
    private(set) var value: T?
    private let constructor: () -> T
    public var wrappedValue: T {
        mutating get {
            if let value = value {
                return value
            }
            let newValue = constructor()
            value = newValue
            return newValue
        }
        set { value = newValue }
    }

    public init(_ constructor: @escaping () -> T) {
        self.constructor = constructor
        self.value = nil
    }
}


@propertyWrapper
public struct LazyInitOnce<T> {
    private(set) var value: T?
    private let constructor: () -> T
    public var wrappedValue: T {
        mutating get {
            if let value = value {
                return value
            }
            let newValue = constructor()
            value = newValue
            return newValue
        }
    }

    public init(_ constructor: @escaping () -> T) {
        self.constructor = constructor
        self.value = nil
    }

    public func `do`(sideEffectTask: (T) -> Void) {
        guard let value = value else { return }
        sideEffectTask(value)
    }
    
}
