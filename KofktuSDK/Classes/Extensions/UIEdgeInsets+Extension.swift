//
//  UIEdgeInsets+Extension.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 4. 6..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation

public extension UIEdgeInsets {
    
    public var width: CGFloat {
        return left + right
    }
    
    public var height: CGFloat {
        return top + bottom
    }
    
}
