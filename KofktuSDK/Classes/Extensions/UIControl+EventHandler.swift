//
//  UIControl+EventHandler.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 4. 6..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

final private class UIControlEventTarget<T: AnyObject> {
    
    typealias EventHandler = (T) -> Void
    
    private weak var owner: T?
    private let handler: EventHandler
    
    init(owner: T, handler: @escaping EventHandler) {
        self.owner = owner
        self.handler = handler
    }
    
    @objc func execute() {
        owner.flatMap {
            handler($0)
        }
    }
}

public protocol UIControlEventHandlerUsable {}
extension UIControl: UIControlEventHandlerUsable {}
public extension UIControlEventHandlerUsable where Self: UIControl {
    
    public func addTarget(_ controlEvent: UIControlEvents, _ handler: @escaping (Self) -> Void) {
        let obj = UIControlEventTarget(owner: self, handler: handler)
        addTarget(obj, action: #selector(obj.execute), for: controlEvent)
        objc_setAssociatedObject(self, "\(arc4random())", obj, .OBJC_ASSOCIATION_RETAIN)
    }
    
}
