//
//  UniqueOwnable.swift
//  KofktuSDK
//
//  Created by kofktu on 2017. 11. 6..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation

protocol UniqueOwnerable {
    associatedtype Unique: Equatable
    var id: Unique { get }
}
