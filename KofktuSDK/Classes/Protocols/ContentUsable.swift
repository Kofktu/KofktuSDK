//
//  ContentUsable.swift
//  KofktuSDK
//
//  Created by kofktu on 2017. 11. 6..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation

public protocol ContentUsable {
    associatedtype Content
}

public protocol SingleContentUsable: ContentUsable {
    var content: Content? { set get }
}

public protocol MultiContentUsable: ContentUsable {
    var contents: [Content]? { get set }
}
