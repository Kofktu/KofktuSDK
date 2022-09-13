//
//  Data+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

public extension Data {
    
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: count), count:count)
        return bytes
            .map { String(format: "%02hhx", $0) }
            .reduce("", { $0 + $1 })
    }
    
}
