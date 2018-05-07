//
//  ApiParameter.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 5. 7..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation

public protocol ApiParameterization {
    typealias Parameters = [String: Any]
    var parameters: Parameters? { get }
}

public struct DefaultApiParameter: ApiParameterization {
    
    private var params: Parameters
    public var parameters: ApiParameterization.Parameters? {
        return params
    }
    
    init(params: Parameters) {
        self.params = params
    }
    
}
