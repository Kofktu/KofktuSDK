//
//  ProcessInfo+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

public extension ProcessInfo {
    
    @inlinable
    var isiOSAppOnSiliconMac: Bool {
        // iOS 14.0 에서 NSInvalidArgumentException raised by -[NSProcessInfo isiOSAppOnMac]: unrecognized selector sent to instance
        guard #available(iOS 14.0.1, iOSApplicationExtension 14.0.1, *) else {
            return false
        }
        
        return isiOSAppOnMac
    }
    
    var isTesting: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }

}
