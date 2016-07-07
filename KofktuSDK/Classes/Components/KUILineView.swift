//
//  UILineView.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@IBDesignable
public class KUILineView: UIView {

    @IBInspectable public var showTopLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var showBottomLine: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var lineHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var lineColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    public var topInsets: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var bottomInsets: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        // Drawing code
        let contextRef = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(contextRef, rect)
        CGContextSetFillColorWithColor(contextRef, backgroundColor?.CGColor)
        CGContextFillRect(contextRef, rect)
        
        CGContextSetFillColorWithColor(contextRef, lineColor.CGColor)
        
        if showTopLine {
            let width = self.width - (topInsets.left + topInsets.right)
            CGContextFillRect(contextRef, CGRectMake(topInsets.left, 0.0, width, lineHeight))
        }
        
        if showBottomLine {
            let width = self.width - (bottomInsets.left + bottomInsets.right)
            CGContextFillRect(contextRef, CGRectMake(bottomInsets.left, self.height - lineHeight, width, lineHeight))
        }
    }

}
