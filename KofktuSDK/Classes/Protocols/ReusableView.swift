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
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public static func instanceFromNib(_ isUseAutoLayout: Bool = true) -> Self? {
        let bundle = Bundle(for: self)
        guard let views = bundle.loadNibNamed(nibName, owner: nil, options: nil) else { return nil }
        for view in views {
            if let view = view as? Self {
                view.translatesAutoresizingMaskIntoConstraints = !isUseAutoLayout
                return view
            }
        }
        return nil
    }
}

extension NibLoadableView where Self: UIViewController {
    public static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public static func instance(nibName: String? = nil) -> Self {
        let bundle = Bundle(for: self)
        return UIViewController(nibName: nibName ?? self.nibName, bundle: bundle) as! Self
    }
    
    public static func instance(storyboard: String) -> Self {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: nibName) as! Self
    }
    
    public static func instanceInitial(storyboard: String) -> Self {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        return storyboard.instantiateInitialViewController() as! Self
    }
}

public protocol ReusableView: class {
    static var reusableIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    public static var reusableIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
