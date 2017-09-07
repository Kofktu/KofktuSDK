//
//  TouchExpandButton.swift
//  KofktuSDK
//
//  Created by kofktu on 2017. 9. 7..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit

open class TouchExpandButton: UIButton {

    @IBInspectable
    public var margin: CGFloat = 0.0
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
    
}
