//
//  ApiResponse.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 5. 7..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import ObjectMapper

public typealias DefaultApiResponseHandler = (ApiResponse?, Error?) -> Void
public typealias IntApiResponseHandler = (Int?, Error?) -> Void

open class ApiResponse: ImmutableModelTypes {
    required public init(map: Map) throws {
    }
}
