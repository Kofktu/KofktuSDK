//
//  UIButton+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public enum UIButtonAlignment {
    case left
    case right
}

public extension UIButton {
    func clearImage(state: UIControl.State) {
        sd_cancelImageLoad(for: state)
        setImage(nil, for: state)
        setBackgroundImage(nil, for: state)
    }
    
    func setBackgroundImage(with urlString: String?, for state: UIControl.State, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        clearImage(state: state)
        setBackgroundImage(placeholder, for: state)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setBackgroundImage(with: url, for: state, completed: { [weak self] (image, error, type, url) in
                self?.setBackgroundImage(image ?? placeholder, for: state)
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
    func setImage(with urlString: String?, for state: UIControl.State, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        clearImage(state: state)
        setImage(placeholder, for: state)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setImage(with: url, for: state, completed: { [weak self] (image, error, type, url) in
                self?.setImage(image ?? placeholder, for: state)
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
    func strechBackgroundImage() {
        let states: [UIControl.State] = [ .normal, .highlighted, .selected, .disabled ]
        
        for state in states {
            guard let image = backgroundImage(for: state) else { continue }
            let size = image.size
            setBackgroundImage(image.stretchableImage(withLeftCapWidth: Int(size.width / 2.0), topCapHeight: Int(size.height / 2.0)), for: state)
        }
    }
    
    func centerVerticallyWithPadding(padding: CGFloat = 6.0) {
        sizeToFit()
        
        guard let imageSize = imageView?.size, let titleSize = titleLabel?.size else {
            return
        }
        
        let iw = imageSize.width
        let ih = imageSize.height
        let tw = titleSize.width
        let th = titleSize.height
        
        let totalHeight = ih + th + padding
        
        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - ih), left: 0.0, bottom: 0.0, right: -tw)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -iw, bottom: -(totalHeight - th), right: 0.0)
    }
    
    func imageAlignment(alignment: UIButtonAlignment) {
        sizeToFit()
        
        guard let imageBounds = imageView?.bounds  else { return }
        guard let titleBounds = titleLabel?.bounds else { return }
        
        switch alignment {
        case .left:
            titleEdgeInsets = UIEdgeInsets.zero
            imageEdgeInsets = UIEdgeInsets.zero
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: titleEdgeInsets.top + 0, left: titleEdgeInsets.left - imageBounds.width, bottom: titleEdgeInsets.bottom, right: titleEdgeInsets.right + imageBounds.width)
            imageEdgeInsets = UIEdgeInsets(top: imageEdgeInsets.top + 0, left: imageEdgeInsets.left + titleBounds.width, bottom: imageEdgeInsets.bottom, right: imageEdgeInsets.right - titleBounds.width)
        }
    }
    
}

public extension UIImageView {
    
    func clearImage() {
        sd_cancelCurrentImageLoad()
        image = nil
    }
    
    func setImage(with urlString: String?, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        sd_cancelCurrentImageLoad()
        image = placeholder
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setImage(with: url, completed: { [weak self] (image, error, type, url) in
                self?.image = image ?? placeholder
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
}

