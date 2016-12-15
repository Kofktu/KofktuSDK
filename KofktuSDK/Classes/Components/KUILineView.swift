//
//  UILineView.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@IBDesignable
open class KUILineView: UIView {

    @IBInspectable open var showTopLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var showBottomLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var lineHeight: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var lineColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    open var topInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var bottomInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    open override func draw(_ rect: CGRect) {
        // Drawing code
        guard let contextRef = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        contextRef.clear(rect)
        
        if let backgroundColor = backgroundColor {
            contextRef.setFillColor(backgroundColor.cgColor)
            contextRef.fill(rect)
        }
        
        contextRef.setFillColor(lineColor.cgColor)
        
        if showTopLine {
            let width = self.width - (topInsets.left + topInsets.right)
            contextRef.fill(CGRect(origin: CGPoint(x: topInsets.left, y: 0.0), size: CGSize(width: width, height: lineHeight)))
        }
        
        if showBottomLine {
            let width = self.width - (bottomInsets.left + bottomInsets.right)
            contextRef.fill(CGRect(origin: CGPoint(x: bottomInsets.left, y: self.height - lineHeight), size: CGSize(width: width, height: lineHeight)))
        }
    }

}
