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
import SDWebImage

/**
 UnableToScanHexValue:      "Scan hex error"
 MismatchedHexStringLength: "Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8"
 */
public enum UIColorInputError : ErrorType {
    case UnableToScanHexValue,
    MismatchedHexStringLength
}

extension UIColor {
    class func colorWith255(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /**
     The shorthand three-digit hexadecimal representation of color.
     #RGB defines to the color #RRGGBB.
     
     - parameter hex3: Three-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #RRGGBBAA.
     
     - parameter hex4: Four-digit hexadecimal value.
     */
    public convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.
     
     - parameter hex6: Six-digit hexadecimal value.
     */
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
     
     - parameter hex8: Eight-digit hexadecimal value.
     */
    public convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.
     
     - parameter rgba: String value.
     */
    public convenience init(hexString: String) throws {
        guard let hexString: String = hexString.substringFromIndex(hexString.startIndex.advancedBy(hexString.hasPrefix("#") ? 1 : 0)),
            var   hexValue:  UInt32 = 0
            where NSScanner(string: hexString).scanHexInt(&hexValue) else {
                throw UIColorInputError.UnableToScanHexValue
        }
        
        switch (hexString.characters.count) {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            throw UIColorInputError.MismatchedHexStringLength
        }
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.
     
     - parameter rgba: String value.
     */
    public convenience init(rgba: String, defaultColor: UIColor = UIColor.clearColor()) {
        guard let color = try? UIColor(hexString: rgba) else {
            self.init(CGColor: defaultColor.CGColor)
            return
        }
        self.init(CGColor: color.CGColor)
    }
    
    /**
     Hex string of a UIColor instance.
     
     - parameter rgba: Whether the alpha should be included.
     */
    public func hexString(includeAlpha: Bool) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    public override var description: String {
        return self.hexString(true)
    }
    
    public override var debugDescription: String {
        return self.hexString(true)
    }
}

public extension UIView {
    
    public var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }
    
    public var x: CGFloat {
        get {
            return CGRectGetMinX(frame)
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    public var y: CGFloat {
        get {
            return CGRectGetMinY(frame)
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    public var right: CGFloat {
        return CGRectGetMaxX(frame)
    }
    
    public var bottom: CGFloat {
        return CGRectGetMaxY(frame)
    }
    
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    
    public var width: CGFloat {
        get {
            return CGRectGetWidth(frame)
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    public var height: CGFloat {
        get {
            return CGRectGetHeight(frame)
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    public func circlize() {
        clipsToBounds = true
        layer.cornerRadius = width / 2.0
    }
    
    public func drawBorder(color: UIColor = UIColor.redColor(), width: CGFloat = 1.0 / UIScreen.mainScreen().scale) {
        layer.borderColor = color.CGColor
        layer.borderWidth = width
    }
    
    public func showGuideLines(width: CGFloat = 1.0 / UIScreen.mainScreen().scale, recursive: Bool = true) {
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
    
    public func addSubviewAtFit(view: UIView, edge: UIEdgeInsets = UIEdgeInsetsZero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(edge.left)-[view]-\(edge.right)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(edge.top)-[view]-\(edge.bottom)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
    }
    
}

public enum UIButtonAlignment {
    case Left
    case Right
}

public extension UIButton {
    
    public func clearImage() {
        sd_cancelImageLoadForState(.Normal)
        setImage(nil, forState: .Normal)
        setBackgroundImage(nil, forState: .Normal)
    }
    
    func setBackgroundImageWithUrlString(urlString: String?, forState state: UIControlState, placeholder: UIImage? = nil, completion: ((image: UIImage?, error: NSError?) -> Void)? = nil) {
        sd_cancelImageLoadForState(state)
        setBackgroundImage(placeholder, forState: .Normal)
        
        if let urlString = urlString {
            sd_setBackgroundImageWithURL(NSURL(string: urlString), forState: state, placeholderImage: placeholder, completed: { [weak self] (image, error, type, url) -> Void in
                self?.setBackgroundImage(image ?? placeholder, forState: .Normal)
                completion?(image: image, error: error)
            })
        } else {
            completion?(image: nil, error: NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
    public func strechBackgroundImage() {
        let states: [UIControlState] = [ .Normal, .Highlighted, .Selected ]
        
        for state in states {
            guard let image = backgroundImageForState(state) else { continue }
            let size = image.size
            setBackgroundImage(image.stretchableImageWithLeftCapWidth(Int(size.width / 2.0), topCapHeight: Int(size.height / 2.0)), forState: state)
        }
    }
    
    public func centerVerticallyWithPadding(padding: CGFloat = 6.0) {
        let imageSize = self.imageView?.size
        let titleSize = self.titleLabel?.size
        let totalHeight = (imageSize?.height ?? 0.0) + (titleSize?.height ?? 0.0) + padding
        
        imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - (imageSize?.height ?? 0)), 0.0, 0.0, -(titleSize?.width ?? 0.0))
        titleEdgeInsets = UIEdgeInsetsMake(0.0, -(imageSize?.width ?? 0), -(totalHeight - (titleSize?.height ?? 0)), 0.0)
    }
    
    public func imageAlignment(alignment: UIButtonAlignment) {
        guard let imageBounds = imageView?.bounds  else { return }
        guard let titleBounds = titleLabel?.bounds else { return }
        
        switch alignment {
        case .Left:
            titleEdgeInsets = UIEdgeInsetsZero
            imageEdgeInsets = UIEdgeInsetsZero
        case .Right:
            titleEdgeInsets = UIEdgeInsetsMake(titleEdgeInsets.top + 0, titleEdgeInsets.left - CGRectGetWidth(imageBounds), titleEdgeInsets.bottom, titleEdgeInsets.right + CGRectGetWidth(imageBounds))
            imageEdgeInsets = UIEdgeInsetsMake(imageEdgeInsets.top + 0, imageEdgeInsets.left + CGRectGetWidth(titleBounds), imageEdgeInsets.bottom, imageEdgeInsets.right - CGRectGetWidth(titleBounds))
        }
    }
    
}

extension UIImageView {
    
    public func clearImage() {
        sd_cancelCurrentImageLoad()
        image = nil
    }
    
    public func setImageWithUrlString(urlString: String?, placeholder: UIImage? = nil, completion: ((image: UIImage?, error: NSError?) -> Void)? = nil) {
        sd_cancelCurrentImageLoad()
        image = placeholder
        
        if let urlString = urlString {
            sd_setImageWithURL(NSURL(string: urlString), placeholderImage: placeholder, completed: { [weak self] (image, error, type, url) -> Void in
                self?.image = image ?? placeholder
                completion?(image: image, error: error)
            })
        } else {
            completion?(image: nil, error: NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
}

extension UITableViewCell: ReusableView {}
public extension UITableView {
    
    public func register<T: UITableViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    public func register<T: UITableViewCell where T: ReusableView, T: NibLoadableView>(_: T.Type) {
        let bundle = NSBundle(forClass: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        registerNib(nib, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    public func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}

extension UICollectionViewCell: ReusableView {}
public extension UICollectionView {
    
    public func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    public func register<T: UICollectionViewCell where T: ReusableView, T: NibLoadableView>(_: T.Type) {
        let bundle = NSBundle(forClass: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        registerNib(nib, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}

public extension UIViewController {
    
    public var topMostViewController: UIViewController {
        return topViewControllerWithRootViewController(self)
    }
    
    public var modalTopViewController: UIViewController {
        if let viewController = presentedViewController {
            return viewController.modalTopViewController
        }
        return self
    }
    
    public var modalTopMostViewController: UIViewController {
        if let viewController = presentedViewController {
            return viewController.modalTopViewController
        }
        return topMostViewController
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController) -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            return self.topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        } else if let naviController = rootViewController as? UINavigationController {
            return self.topViewControllerWithRootViewController(naviController.viewControllers.last!)
        } else if let viewController = rootViewController.presentedViewController {
            return self.topViewControllerWithRootViewController(viewController)
        }
        
        return rootViewController
    }
    
    public func dismissAllModalViewController() {
        if let viewController = presentedViewController {
            viewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.dismissAllModalViewController()
            })
        } else {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
}

public extension UINavigationController {
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.viewControllers.last?.preferredStatusBarStyle() ?? .Default
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return self.viewControllers.last?.prefersStatusBarHidden() ?? false
    }
    
    override public func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return self.viewControllers.last?.preferredStatusBarUpdateAnimation() ?? .Fade
    }
    
    override public func shouldAutorotate() -> Bool {
        return self.viewControllers.last?.shouldAutorotate() ?? true
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.viewControllers.last?.supportedInterfaceOrientations() ?? .All
    }
}

public extension UIApplication {
    
    public var enabledRemoteNotification: Bool {
        return UIApplication.sharedApplication().currentUserNotificationSettings()?.types.contains(.Alert) ?? false
    }

}