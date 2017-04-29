//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

public struct LoggerStyle: OptionSet, Hashable {
    public var rawValue: UInt
    public var hashValue: Int
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
        self.hashValue = Int(rawValue)
    }
    
    static let debug    = LoggerStyle(rawValue: 1 << 0)
    static let info     = LoggerStyle(rawValue: 1 << 1)
    static let warning  = LoggerStyle(rawValue: 1 << 2)
    static let error    = LoggerStyle(rawValue: 1 << 3)
}

public let Log: Logger = {
    return Logger.shared
}()

public class Logger {
    fileprivate static let shared: Logger = {
        return Logger()
    }()
    
    #if DEBUG
        public static var isEnabled = true
    #else
        public static var isEnabled = false
    #endif
    
    public var style: LoggerStyle = []
    
    // MARK: - Log
    public func d<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard style.contains(.debug), Logger.isEnabled else {
            return
        }
        
        print("[DEBUG] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    public func i<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard style.contains(.info), Logger.isEnabled else {
            return
        }
        
        print("[INFO] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    public func w<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard style.contains(.warning), Logger.isEnabled else {
            return
        }
        
        print("[WARNING] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    public func e(_ error: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard let error = error, style.contains(.error) && Logger.isEnabled else {
            return
        }
        
        print("\(file.lastPathComponent).\(function)[\(line)] : ===========[ERROR]============", terminator: "\n")
        print("Code : \(error.code)", terminator: "\n")
        print("Description : \(error.localizedDescription)", terminator: "\n")
        
        if style.contains(.debug) {
            if let reason = error.localizedFailureReason {
                print("[DEBUG] Reason : \(reason)", terminator: "\n")
            }
            if let suggestion = error.localizedRecoverySuggestion {
                print("[DEBUG] Suggestion : \(suggestion)", terminator: "\n")
            }
        }
        print("==============================================================================", terminator: "\n")
    }
}
