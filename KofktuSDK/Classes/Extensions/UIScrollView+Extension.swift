//
//  UIScrollView+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public extension UIScrollView {
    
    func scrollToTop(animated: Bool = true) {
        let offset = CGPoint(x: 0.0, y: -contentInset.top)
        setContentOffset(offset, animated: animated)
    }
    
    func scrollToBottom(animated: Bool = true) {
        let y = max(-contentInset.top, contentSize.height - height + contentInset.bottom)
        let offset = CGPoint(x: 0.0, y: y)
        setContentOffset(offset, animated: animated)
    }
}

public extension UITableViewCell {
    
    func hiddenSepratorLine() {
        separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 10000000.0)
    }
    
}
