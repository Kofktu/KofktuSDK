//
//  CircleComponent.swift
//  KofktuSDK
//
//  Created by kofktu on 2017. 9. 7..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class CornerRadiusButton: TouchExpandButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
}

@IBDesignable
open class CircleButton: TouchExpandButton {

    open override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
          layer.cornerRadius = bounds.height / 2.0
    }
}

@IBDesignable
open class CircleImageView: UIImageView {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
    
}
