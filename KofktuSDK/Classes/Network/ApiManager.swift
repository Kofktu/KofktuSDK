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
    public static var logStyle: Style = .Light
    public static var timeoutIntervalForRequest: NSTimeInterval = 15.0
}

public class ApiManager: Alamofire.Manager {
    
    public static let sharedManager: ApiManager = {
        if ApiManagerConfig.logStyle == .Light {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = ApiManagerConfig.timeoutIntervalForRequest
            return ApiManager(configuration: configuration)
        } else {
            Timberjack.logStyle = ApiManagerConfig.logStyle
            let configuration = Timberjack.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = ApiManagerConfig.timeoutIntervalForRequest
            return ApiManager(configuration: configuration)
        }
    }()
    
}
