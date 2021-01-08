//
//  Array+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

public extension Array {

    func filter(duplicates includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element] {
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }

    @discardableResult
    mutating func remove<T: Equatable>(object: T) -> Bool {
        for (index, obj) in enumerated() {
            if let to = obj as? T, to == object {
                remove(at: index)
                return true
            }
        }
        return false
    }
    
    mutating func suffle() {
        guard count > 1 else { return }
        
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swapAt(i, j)
        }
    }
    
    func join(with separator: String, toString: (Element) -> String?) -> String {
        var stringArray = Array<String>()
        for element in self {
            if let string = toString(element) {
                stringArray.append(string)
            }
        }
        return stringArray.joined(separator: separator)
    }
    
}
