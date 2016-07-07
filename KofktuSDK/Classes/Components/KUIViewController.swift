//
//  KUIViewController.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

public class KUIViewController: UIViewController {

    internal var isFirstViewAppeared: Bool = true

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isFirstViewAppeared = false
    }
}
