//
//  KofktuSDK.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

public func dispatch_main_safe(sync closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.sync {
            closure()
        }
    }
}

public func dispatch_main_safe(async closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

public func dispatch_after(delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
}
