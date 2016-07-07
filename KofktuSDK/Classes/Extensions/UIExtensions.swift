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

enum UIButtonAlignment {
    case Left
    case Right
}

extension UIButton {
    
    func strechBackgroundImage() {
        let states: [UIControlState] = [ .Normal, .Highlighted, .Selected ]
        
        for state in states {
            guard let image = backgroundImageForState(state) else { continue }
            let size = image.size
            setBackgroundImage(image.stretchableImageWithLeftCapWidth(Int(size.width / 2.0), topCapHeight: Int(size.height / 2.0)), forState: state)
        }
    }
    
    func centerVerticallyWithPadding(padding: CGFloat = 6.0) {
        let imageSize = self.imageView?.size
        let titleSize = self.titleLabel?.size
        let totalHeight = (imageSize?.height ?? 0.0) + (titleSize?.height ?? 0.0) + padding
        
        imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - (imageSize?.height ?? 0)), 0.0, 0.0, -(titleSize?.width ?? 0.0))
        titleEdgeInsets = UIEdgeInsetsMake(0.0, -(imageSize?.width ?? 0), -(totalHeight - (titleSize?.height ?? 0)), 0.0)
    }
    
    func imageAlignment(alignment: UIButtonAlignment) {
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

extension UITableViewCell: ReusableView {}
extension UITableView {
    
    func register<T: UITableViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    func register<T: UITableViewCell where T: ReusableView, T: NibLoadableView>(_: T.Type) {
        let bundle = NSBundle(forClass: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        registerNib(nib, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}

extension UICollectionViewCell: ReusableView {}
extension UICollectionView {
    
    func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    func register<T: UICollectionViewCell where T: ReusableView, T: NibLoadableView>(_: T.Type) {
        let bundle = NSBundle(forClass: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        registerNib(nib, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}

extension UIViewController {
    
    var topMostViewController: UIViewController {
        return topViewControllerWithRootViewController(self)
    }
    
    var modalTopViewController: UIViewController {
        if let viewController = presentedViewController {
            return viewController.modalTopViewController
        }
        return self
    }
    
    var modalTopMostViewController: UIViewController {
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
    
    func dismissAllModalViewController() {
        if let viewController = presentedViewController {
            viewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.dismissAllModalViewController()
            })
        } else {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
}

extension UINavigationController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.viewControllers.last?.preferredStatusBarStyle() ?? .Default
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.viewControllers.last?.prefersStatusBarHidden() ?? false
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return self.viewControllers.last?.preferredStatusBarUpdateAnimation() ?? .Fade
    }
    
    override func shouldAutorotate() -> Bool {
        return self.viewControllers.last?.shouldAutorotate() ?? true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.viewControllers.last?.supportedInterfaceOrientations() ?? .All
    }
}

extension UIApplication {
    
    var enabledRemoteNotification: Bool {
        return UIApplication.sharedApplication().currentUserNotificationSettings()?.types.contains(.Alert) ?? false
    }

}