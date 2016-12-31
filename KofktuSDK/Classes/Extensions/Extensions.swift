//
//  Extensions.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

extension Array {
    public mutating func remove<T: Equatable>(object: T) -> Bool {
        for (index, obj) in enumerated() {
            if let to = obj as? T, to == object {
                remove(at: index)
                return true
            }
        }
        return false
    }
    
    public mutating func suffle() {
        guard count > 1 else { return }
        
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
    
    public func join(with separator: String, toString: (Element) -> String?) -> String {
        var stringArray = Array<String>()
        for element in self {
            if let string = toString(element) {
                stringArray.append(string)
            }
        }
        return stringArray.joined(separator: separator)
    }
}

extension Dictionary {
    public mutating func merge(dict: [Key: Value]) {
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
}

extension String {
    public var urlEncoded: String? {
        let characterSet = NSCharacterSet(charactersIn: "\n ;:\\@&=+$,/?%#[]|\"<>").inverted
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
    
    public var urlDecoded: String? {
        return removingPercentEncoding
    }
    
    public var base64Encoded: String? {
        return data(using: .utf8, allowLossyConversion: true)?.base64EncodedString(options: [])
    }
    
    public var base64Decoded: String? {
        guard let data = Data(base64Encoded: self, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return NSString(format: format, arguments: getVaList(args)) as String
    }
    
    public func indexOf(string: String) -> Int? {
        guard let range = range(of: string) else { return nil }
        return characters.distance(from: startIndex, to: range.lowerBound)
    }
    
    public subscript (range: Range<Int>) -> String? {
        let count = characters.count
        
        //Check for out of boundary condition
        if count < range.upperBound || count < range.lowerBound { return nil }
        
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    public func queryTokenizing() -> [String: String] {
        var result: [String:String] = [:]
        let tokens = characters.split(separator: "&").map(String.init)
        for token in tokens {
            if let index = token.characters.index(of: "=") {
                result[token.substring(to: index)] = token.substring(from: token.index(index, offsetBy: 1))
            }
        }
        return result
    }
}

extension UserDefaults {
    public class func disableLayoutConstraintLog() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
