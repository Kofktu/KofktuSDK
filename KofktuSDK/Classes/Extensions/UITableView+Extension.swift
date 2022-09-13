//
//  UITableView+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell: ReusableView {}
public extension UITableView {
    
    func register<T: UITableViewCell>(withReuseIdentifier: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(`for` indexPath: IndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
    func selectedAll(`in` section: Int) {
        for row in 0 ..< numberOfRows(inSection: section) {
            selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
        }
    }
    
    func deselectedAll(`in` section: Int) {
        for row in 0 ..< numberOfRows(inSection: section) {
            deselectRow(at: IndexPath(row: row, section: section), animated: false)
        }
    }
    
}
