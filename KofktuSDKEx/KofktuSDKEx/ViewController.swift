//
//  ViewController.swift
//  KofktuSDKEx
//
//  Created by Kofktu on 2016. 7. 31..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import KofktuSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        testToastController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    private func testToastController() {
        KUIToastController.shared.show(message: "테스트")
        KUIToastController.shared.show(message: "테스트")
        KUIToastController.shared.show(message: "테스트")
        KUIToastController.shared.show(message: "테스트")
        KUIToastController.shared.show(message: "테스트1")
        KUIToastController.shared.show(message: "테스트2")
    }
}

