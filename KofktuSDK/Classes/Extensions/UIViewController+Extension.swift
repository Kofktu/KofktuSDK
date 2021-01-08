//
//  UIViewController+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: NibLoadableView {}
public extension UIViewController {
    
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
    
    private func topViewControllerWithRootViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        } else if let naviController = rootViewController as? UINavigationController {
            return topViewControllerWithRootViewController(naviController.viewControllers.last!)
        } else if let viewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(viewController)
        }
        
        return rootViewController
    }
    
    func dismissAllModalViewController() {
        if let viewController = presentedViewController {
            viewController.dismiss(animated: false, completion: {
                self.dismissAllModalViewController()
            })
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
}
