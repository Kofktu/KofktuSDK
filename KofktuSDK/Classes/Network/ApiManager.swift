//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Timberjack

struct ApiManagerConfig {
    static let logStyle: Style = .Light
    static let timeoutIntervalForRequest: NSTimeInterval = 15.0
}

class ApiManager: Alamofire.Manager {
    
    static let sharedManager: ApiManager = {
        Timberjack.register()
        Timberjack.logStyle = ApiManagerConfig.logStyle
        let configuration = Timberjack.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = ApiManagerConfig.timeoutIntervalForRequest
        let manager = ApiManager(configuration: configuration)
        return manager
    }()
    
}
