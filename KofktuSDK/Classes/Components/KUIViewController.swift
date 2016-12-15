//
//  KUIViewController.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

open class KUIViewController: UIViewController {

    open var isFirstViewAppeared: Bool = true

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFirstViewAppeared = false
    }
}
