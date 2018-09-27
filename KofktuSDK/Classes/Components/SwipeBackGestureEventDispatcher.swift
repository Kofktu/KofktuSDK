//
//  SwipeBackGestureEventDispatcher.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 4. 6..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public class SwipeBackGestureEventDispatcher: NSObject {
    
    private weak var parentViewController: UIViewController?
    private var panGesture: UIPanGestureRecognizer!
    
    public init(parentViewController: UIViewController) {
        super.init()
        self.parentViewController = parentViewController
        setupPanGesture()
    }
    
    // MARK: - Private
    private func setupPanGesture() {
        guard let navigationController = parentViewController?.navigationController, navigationController.viewControllers.count > 1 else {
            return
        }
        
        guard let targets = navigationController.interactivePopGestureRecognizer?.value(forKey: "_targets") as? [AnyObject] else {
            return
        }
        
        let target = targets.first?.value(forKey: "target") as AnyObject
        let selector = NSSelectorFromString("handleNavigationTransition:")
        
        guard target.responds(to: selector) else {
            return
        }
        
        panGesture = UIPanGestureRecognizer(target: target, action: selector)
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        parentViewController?.view.addGestureRecognizer(panGesture)
    }
    
}

extension SwipeBackGestureEventDispatcher: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture == panGesture else {
            return false
        }
        
        let velocity = gesture.velocity(in: parentViewController?.view)
        return velocity.x > 0.0 && abs(velocity.x) > abs(velocity.y)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: gestureRecognizer.view)
        var view = gestureRecognizer.view?.hitTest(point, with: nil)
        
        let targetView = self.parentViewController?.view.subviews.lazy.compactMap { $0 as? UIScrollView }.first
        
        if let scrollView = targetView {
            let contentOffset = scrollView.contentOffset
            let contentSize = scrollView.contentSize
            
            if contentSize.width > scrollView.width &&
                contentOffset.x > 0 {
                return false
            }
            
            return true
        } else {
            while let candidate = view {
                if let scrollView = candidate as? UIScrollView {
                    let contentOffset = scrollView.contentOffset
                    let contentSize = scrollView.contentSize
                    
                    if contentSize.width > scrollView.width &&
                        contentOffset.x > 0 {
                        return false
                    }
                    
                    return true
                }
                view = candidate.superview
            }
        }
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == panGesture
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture
    }
    
}

