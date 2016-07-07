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
    static public var nibName: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    static public func instanceFromNib() -> NibLoadableView? {
        let bundle = NSBundle(forClass: self)
        let views = bundle.loadNibNamed(nibName, owner: nil, options: nil)
        for view in views {
            if let view = view as? Self {
                return view
            }
        }
        return nil
    }
}

public protocol ReusableView: class {
    static var reusableIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static public var reusableIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}