//
//  UICollectionView+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell: ReusableView {}
public extension UICollectionView {
    
    func register<T: UICollectionViewCell>(withReuseIdentifier: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    func register<T: UICollectionViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(`for` indexPath: IndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}
