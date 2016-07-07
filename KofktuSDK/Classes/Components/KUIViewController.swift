//
//  KUIViewController.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

class KUIViewController: UIViewController {

    var isFirstViewAppeared: Bool = true

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isFirstViewAppeared = false
    }
}
