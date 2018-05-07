//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation
import Dotzu

public struct LoggerStyle: OptionSet, Hashable {
    public var rawValue: UInt
    public var hashValue: Int
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
        self.hashValue = Int(rawValue)
    }
    
    static public let debug     = LoggerStyle(rawValue: 1 << 0)
    static public let info      = LoggerStyle(rawValue: 1 << 1)
    static public let warning   = LoggerStyle(rawValue: 1 << 2)
    static public let error     = LoggerStyle(rawValue: 1 << 3)
    static public let dotzu     = LoggerStyle(rawValue: 1 << 4)
}

public let Log: KLogger = {
    return KLogger.shared
}()

public class KLogger {
    fileprivate static let shared = KLogger()
    
    #if DEBUG
        public var isEnabled = true
    public var style: LoggerStyle = [.debug, .warning, .info, .error] {
        didSet {
            if isEnabled {
                if style.contains(.dotzu) {
                    Dotzu.enable()
                } else {
                    Dotzu.disable()
                }
            }
        }
    }
    #else
        public var isEnabled = false
        public var style: LoggerStyle = []
    #endif
    
    // MARK: - Log
    public func d<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else {
            return
        }
        
        if style.contains(.debug) {
            print("[DEBUG] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
        }
        
        if style.contains(.dotzu) {
            Logger.verbose(value, file: (file as String), function: function, line: line)
        }
    }
    
    public func i<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else {
            return
        }
        
        if style.contains(.info) {
            print("[INFO] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
        }
        
        if style.contains(.dotzu) {
            Logger.info(value, file: (file as String), function: function, line: line)
        }
    }
    
    public func w<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else {
            return
        }
        
        if style.contains(.warning) {
            print("[WARNING] \(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
        }
        
        if style.contains(.dotzu) {
            Logger.warning(value, file: (file as String), function: function, line: line)
        }
    }
    
    public func e(_ nsError: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard let error = nsError, isEnabled else {
            return
        }
        
        if style.contains(.error) {
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
        
        if style.contains(.dotzu) {
            Logger.error(error, file: (file as String), function: function, line: line)
        }
    }
    
    public func e(_ error: Error?, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard let error = error, isEnabled else {
            return
        }
        
        if style.contains(.error) {
            print("\(file.lastPathComponent).\(function)[\(line)] : ===========[ERROR]============", terminator: "\n")
            print("Description : \(error.localizedDescription)", terminator: "\n")
            print("==============================================================================", terminator: "\n")
        }
        
        if style.contains(.dotzu) {
            Logger.error(error, file: (file as String), function: function, line: line)
        }
    }
}
