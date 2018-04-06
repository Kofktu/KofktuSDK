//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Sniffer
import Dotzu

public protocol ApiRequestProtocol {
    var baseURL: URL { get }
    var method: Alamofire.HTTPMethod { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    var resourcePath: String { get }
    /**
     * JSONEncoding.default
     * URLEncoding.default
     * ArrayEncoding.default
     */
    var encoding: Alamofire.ParameterEncoding { get }
}
