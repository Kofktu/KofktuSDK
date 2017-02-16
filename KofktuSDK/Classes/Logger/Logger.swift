//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

public enum Style {
    case none
    case light
    case verbose
}

open class Logger: URLProtocol {
    open static let shared: Logger = {
        return Logger()
    }()
    open static var style: Style = .light
    
    // MARK: - Log
    open func d<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard Logger.style == .verbose else { return }
        print("\(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    open func e(_ error: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard Logger.style != .none else { return }
        if let error = error {
            print("\(file.lastPathComponent).\(function)[\(line)] : ===========[ERROR]============", terminator: "\n")
            print("Code : \(error.code)", terminator: "\n")
            print("Description : \(error.localizedDescription)", terminator: "\n")
            
            if Logger.style == .verbose {
                if let reason = error.localizedFailureReason {
                    print("Reason : \(reason)", terminator: "\n")
                }
                if let suggestion = error.localizedRecoverySuggestion {
                    print("Suggestion : \(suggestion)", terminator: "\n")
                }
            }
            print("==============================================================================", terminator: "\n")
        } else {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] error is null", terminator: "\n")
        }
    }
}

public let Log: Logger? = {
    guard Logger.style != .none else { return nil }
    return Logger.shared
}()

