//
//  Extensions.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

extension Array {
    
    public mutating func suffle() {
        guard count > 1 else { return }
        
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
    
    public func joinWithSeparator(separator: String, toString: (Element) -> String?) -> String {
        var stringArray = Array<String>()
        for element in self {
            if let string = toString(element) {
                stringArray.append(string)
            }
        }
        return stringArray.joinWithSeparator(separator)
    }
    
}

extension Dictionary {
    
    public mutating func merge(dict: [Key: Value]){
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
    
}

extension String {
    
    public var urlEncoded: String? {
        let characterSet = NSCharacterSet(charactersInString: "\n ;:\\@&=+$,/?%#[]|\"<>").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
    public var urlDecoded: String? {
        return stringByRemovingPercentEncoding
    }
    
    public var base64Encoded: String? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        return data?.base64EncodedStringWithOptions([])
    }
    
    public var base64Decoded: String? {
        if let data = NSData(base64EncodedString: self, options: []) {
            if let decoded = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return decoded as String
            }
        }
        return nil
    }
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(args: CVarArgType...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return NSString(format: format, arguments: getVaList(args)) as String
    }
    
    public func indexOf(string: String) -> Int? {
        guard let range = rangeOfString(string) else { return nil }
        return startIndex.distanceTo(range.startIndex)
    }
    
    public subscript (range: Range<Int>) -> String? {
        let count = characters.count as Int
        
        //Check for out of boundary condition
        if count < range.endIndex || count < range.startIndex { return nil }
        
        let start = startIndex.advancedBy(range.startIndex)
        let end   = startIndex.advancedBy(range.endIndex)
        
        return self[start..<end]
    }
    
    public func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    public func queryTokenizing() -> [String: String] {
        var result:[String:String] = [:]
        let tokens = self.characters.split("&").map(String.init)
        for token in tokens {
            if let index = token.characters.indexOf("=") {
                result[token.substringToIndex(index)] = token.substringFromIndex(index.advancedBy(1))
            }
        }
        return result
    }
}

extension NSUserDefaults {
    
    public class func disableLayoutConstraintLog() {
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
