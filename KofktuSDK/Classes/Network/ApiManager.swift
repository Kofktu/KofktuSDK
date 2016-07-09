//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Timberjack

public struct ApiManagerConfig {
    public static let logStyle: Style = .Light
    public static let timeoutIntervalForRequest: NSTimeInterval = 15.0
}

public class ApiManager: Alamofire.Manager {
    
    public static let sharedManager: ApiManager = {
        Timberjack.register()
        Timberjack.logStyle = ApiManagerConfig.logStyle
        let configuration = Timberjack.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = ApiManagerConfig.timeoutIntervalForRequest
        let manager = ApiManager(configuration: configuration)
        return manager
    }()
    
}
