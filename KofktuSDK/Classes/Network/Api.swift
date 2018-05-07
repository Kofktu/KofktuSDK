//
//  Api.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 5. 7..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import Alamofire

public protocol ApiRootURLConvertible {
    var urlString: String { get }
}

public protocol ApiPath {
    var rootURL: ApiRootURLConvertible { get }
    var resourcePath: String { get }
}

public enum Timeout: TimeInterval {
    case ten = 10.0
    case fifteen = 15.0
    case twenty = 20.0
    case sixty = 60.0
    case `default` = 6.0
}

public protocol TimeoutIntervalOwnable {
    var timeoutInterval: Timeout { get }
}

extension TimeoutIntervalOwnable {
    var timeoutInterval: Timeout {
        return .ten
    }
}

public protocol RetryEnable {
    var retryCount: Int { set get }
}

extension RetryEnable {
    private var maxRetryCount: Int {
        return 1
    }
    
    var canRetry: Bool {
        return retryCount < maxRetryCount
    }
}

public protocol Api: ApiPath, TimeoutIntervalOwnable {
    var encoding: Alamofire.ParameterEncoding { get }
    var method: Alamofire.HTTPMethod { get }
}

extension Api {
    var encoding: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }
}
