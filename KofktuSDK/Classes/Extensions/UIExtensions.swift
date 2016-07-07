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

public extension UITableViewCell: ReusableView {}
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

public extension UICollectionViewCell: ReusableView {}
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