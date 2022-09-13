//
//  UIRefreshControl+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public extension UIRefreshControl {
    
    func moveTo(offsetY: CGFloat) {
        bounds = CGRect(origin: CGPoint(x: bounds.origin.x, y: offsetY), size: bounds.size)
        beginRefreshing()
        endRefreshing()
    }
    
}
