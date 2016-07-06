//
//  UIExtensions.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 6..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import CoreGraphics
import UIKit

extension UIView {
    
    var x: CGFloat {
        get {
            return CGRectGetMinX(frame)
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
}