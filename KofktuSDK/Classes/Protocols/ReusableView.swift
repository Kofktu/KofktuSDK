//
//  ReusableView.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

public protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    public static var nibName: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public static func instanceFromNib() -> Self? {
        let bundle = NSBundle(forClass: self)
        let views = bundle.loadNibNamed(nibName, owner: nil, options: nil)
        for view in views! {
            if let view = view as? Self {
                return view
            }
        }
        return nil
    }
}

extension NibLoadableView where Self: UIViewController {
    public static var nibName: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public static func instance(nibName nibName: String? = nil) -> Self? {
        let bundle = NSBundle(forClass: self)
        return UIViewController(nibName: nibName ?? self.nibName, bundle: bundle) as? Self
    }
    
    public static func instance(storyboard storyboard: String, initial: Bool = false) -> Self? {
        let bundle = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        if initial { return storyboard.instantiateInitialViewController() as? Self }
        return storyboard.instantiateViewControllerWithIdentifier(nibName) as? Self
    }
}

public protocol ReusableView: class {
    static var reusableIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    public static var reusableIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}
