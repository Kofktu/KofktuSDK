//
//  UIApplication+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    
    var enabledRemoteNotification: Bool {
        UIApplication.shared.currentUserNotificationSettings?.types.contains([.alert]) ?? false
    }
    
}
