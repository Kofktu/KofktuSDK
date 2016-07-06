//
//  UIExtensions.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 6..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import CoreGraphics
import UIKit
import QuartzCore

extension UIView {
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }
    
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
    
    var y: CGFloat {
        get {
            return CGRectGetMinY(frame)
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var right: CGFloat {
        return CGRectGetMaxX(frame)
    }
    
    var bottom: CGFloat {
        return CGRectGetMaxY(frame)
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    
    var width: CGFloat {
        get {
            return CGRectGetWidth(frame)
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return CGRectGetHeight(frame)
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    func circlize() {
        clipsToBounds = true
        layer.cornerRadius = width / 2.0
    }
    
    func drawBorder(color: UIColor = UIColor.redColor(), width: CGFloat = 1.0 / UIScreen.mainScreen().scale) {
        layer.borderColor = color.CGColor
        layer.borderWidth = width
    }
    
    func showGuideLines(width: CGFloat = 1.0 / UIScreen.mainScreen().scale, recursive: Bool = true) {
        drawBorder(UIColor(
                            red: CGFloat(arc4random_uniform(255) + 1) / 255.0,
                            green: CGFloat(arc4random_uniform(255) + 1) / 255.0,
                            blue: CGFloat(arc4random_uniform(255) + 1) / 255.0,
                            alpha: 1.0
                            ),
                   width: width)
        
        if recursive {
            for subview in subviews {
                subview.showGuideLines()
            }
        }
    }
    
    func addSubviewAtFit(view: UIView, edge: UIEdgeInsets = UIEdgeInsetsZero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(edge.left)-[view]-\(edge.right)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(edge.top)-[view]-\(edge.bottom)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
    }
    
}