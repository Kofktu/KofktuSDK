//
//  RequestLoader.swift
//  KofktuSDK
//
//  Created by Kofktu on 2017. 1. 24..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation

public struct RequestLoader {
    public var loading = false
    public var hasMore = true
    public var reloaded = false
    public var page = 0
    public var countPerPage = 20
    public var canRequest: Bool {
        return !loading && hasMore
    }
    
    public init(countPerPage: Int = 20) {
        loading = false
        hasMore = true
        reloaded = false
        page = 0
        self.countPerPage = countPerPage
    }
    
    mutating public func reload() {
        page = 0
        reloaded = true
        loading = false
        hasMore = true
    }
    
    mutating public func startLoading() {
        loading = true
    }
    
    mutating public func endLoading() {
        reloaded = false
        loading = false
    }
    
    mutating public func resultCount(_ count: Int?) {
        hasMore = count ?? 0 == countPerPage
    }
}
