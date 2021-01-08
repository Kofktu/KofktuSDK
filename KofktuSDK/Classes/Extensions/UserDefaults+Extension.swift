//
//  UserDefaults+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    static func disableLayoutConstraintLog() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
    func set<T: BaseMappable>(object: T?, forKey key: String) {
        set(object?.toJSONString(), forKey: key)
    }
    
    func object<T: BaseMappable>(forKey key: String) -> T? {
        return string(forKey: key).flatMap { Mapper<T>().map(JSONString: $0) }
    }
    
}
