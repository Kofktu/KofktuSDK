//
//  KeychainManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2017. 1. 1..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit
import KeychainAccess

public class KeychainManager {
    static public let shared = KeychainManager()
    
    public var isSynchronizeWithICloud: Bool {
        get {
            return keychain.synchronizable
        }
        set {
            let _ = keychain.synchronizable(newValue)
        }
    }
    
    fileprivate lazy var keychain: Keychain = {
        return Keychain(service: Bundle.main.bundleIdentifier!)
    }()
    
    public func set(string value: String?, for key: String) {
        keychain[string: key] = value
    }
    
    public func set(data value: Data?, for key: String) {
        keychain[data: key] = value
    }
    
    public func get(string key: String) -> String? {
        return keychain[string: key]
    }
    
    public func get(data key: String) -> Data? {
        return keychain[data: key]
    }
}
