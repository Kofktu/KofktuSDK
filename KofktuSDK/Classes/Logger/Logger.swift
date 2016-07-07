//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

let Log: Logger? = {
    #if DEBUG
        return Logger()
    #else
        return nil
    #endif
}()

struct Logger {
    
    func d<T>(value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        print("\(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    func e(error: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] code : \(error.code)", terminator: "\n")
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] description : \(error.localizedDescription)", terminator: "\n")
        } else {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] error is null", terminator: "\n")
        }
    }
}
