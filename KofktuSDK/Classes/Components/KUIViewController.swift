//
//  KUIViewController.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

open class KUIViewController: UIViewController {

    public private(set) var isViewAppeared = false
    public private(set) var isFirstViewAppeared = true
    
    private var isNeedUpdateData = false

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppeared = true
        
        if isNeedUpdateData {
            updateData()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppeared = false
        isFirstViewAppeared = false
    }
    
    @objc open func setNeedUpdateData() {
        isNeedUpdateData = true
        
        if isViewAppeared {
            updateData()
        }
    }
    
    open func updateData() {
        isNeedUpdateData = false
    }
    
}
