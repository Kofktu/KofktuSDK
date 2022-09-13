//
//  UIView+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

extension UIView: NibLoadableView {}
public extension UIView {
    
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
            return frame.minX
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var y: CGFloat {
        get {
            return frame.minY
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var right: CGFloat {
        return frame.maxX
    }
    
    var bottom: CGFloat {
        return frame.maxY
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
            return frame.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    func circlize() {
        clipsToBounds = true
        layer.cornerRadius = width / 2.0
    }
    
    func capture(_ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let alpha = self.alpha
        let isHidden = self.isHidden
        
        defer {
            self.alpha = alpha
            self.isHidden = isHidden
            UIGraphicsEndImageContext()
        }
        
        self.alpha = 1.0
        self.isHidden = false
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: contextRef)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func drawBorder(_ color: UIColor = UIColor.red, width: CGFloat = 1.0 / UIScreen.main.scale) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func showGuideLines(_ width: CGFloat = 1.0 / UIScreen.main.scale, recursive: Bool = true) {
        drawBorder(UIColor(
            red: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            green: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            blue: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            alpha: 1.0),
                   width: width)
        
        if recursive {
            for subview in subviews {
                subview.showGuideLines()
            }
        }
    }
    
    func addSubviewAtFit(_ view: UIView, edge: UIEdgeInsets = UIEdgeInsets.zero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(edge.left)-[view]-\(edge.right)-|", views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(edge.top)-[view]-\(edge.bottom)-|", views: ["view": view]))
    }
    
}

public extension NSLayoutConstraint {
    class func constraints(withVisualFormat format: String, views: [String : Any]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
    }
}
