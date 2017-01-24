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
        url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL
        apns = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        
        if #available(iOS 9.0, *) {
            shortcut = (launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem)?.userInfo
        }
    }
    
    mutating public func finished() {
        initialized = true
        apns = nil
        url = nil
        shortcut = nil
    }
}
