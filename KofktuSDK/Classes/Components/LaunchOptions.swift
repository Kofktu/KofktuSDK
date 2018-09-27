//
//  LaunchOptions.swift
//  KofktuSDK
//
//  Created by Kofktu on 2017. 1. 24..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation

public struct LaunchOptions {
    public var initialized = false
    public var apns: [AnyHashable: Any]?
    public var url: URL?
    public var shortcut: [String: NSSecureCoding]?
    
    public init(launchOptions: [AnyHashable: Any]?) {
        url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        apns = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        
        if #available(iOS 9.0, *) {
            shortcut = (launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem)?.userInfo
        }
    }
    
    mutating public func finished() {
        initialized = true
        apns = nil
        url = nil
        shortcut = nil
    }
}
