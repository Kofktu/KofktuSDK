//
//  Extensions.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func suffle() {
        guard count > 1 else { return }
        
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
    
}

extension Dictionary {
    
    mutating func merge(dict: [Key: Value]){
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
    
}

extension String {
    
    var urlEncoded: String? {
        let characterSet = NSCharacterSet(charactersInString: "\n ;:\\@&=+$,/?%#[]|\"<>").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
    var urlDecoded: String? {
        return stringByRemovingPercentEncoding
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(args: CVarArgType...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return NSString(format: format, arguments: getVaList(args)) as String
    }
    
    func indexOf(string: String) -> Int? {
        guard let range = rangeOfString(string) else { return nil }
        return startIndex.distanceTo(range.startIndex)
    }
    
    subscript (range: Range<Int>) -> String? {
        let count = characters.count as Int
        
        //Check for out of boundary condition
        if count < range.endIndex || count < range.startIndex { return nil }
        
        let start = startIndex.advancedBy(range.startIndex)
        let end   = startIndex.advancedBy(range.endIndex)
        
        return self[start..<end]
    }
    
    func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
}