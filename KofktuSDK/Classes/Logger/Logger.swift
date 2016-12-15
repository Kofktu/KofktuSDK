//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation
import Timberjack

public struct Logger {
    
    public static let shared: Logger = {
        return Logger()
    }()
    public static var style: Style = .light

    public func d<T>(value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        print("\(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    public func e(error: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] code : \(error.code)", terminator: "\n")
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] description : \(error.localizedDescription)", terminator: "\n")
        } else {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] error is null", terminator: "\n")
        }
    }
}

public let Log: Logger? = {
    if Logger.style == .verbose {
        return Logger.shared
    }
    return nil
}()
