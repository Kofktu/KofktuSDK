//
//  Extensions.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

public extension IntegerLiteralType {
    
    public var f: CGFloat {
        return CGFloat(self)
    }
    
}

public extension FloatLiteralType {
    
    public var f: CGFloat {
        return CGFloat(self)
    }
    
}

public extension Array {
    
    @discardableResult
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
            swapAt(i, j)
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

public extension Dictionary {
    
    public mutating func merge(dict: [Key: Value]) {
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
    
}

public extension Int {
    
    public var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? String(self)
    }
    
}

public extension String {
    
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
    
    public subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    // for convenience we should include String return
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)
        
        return String(self[start...end])
    }
    
    public func substring(from: Int) -> String {
        let start = characters.index(startIndex, offsetBy: from)
        return String(self[start...])
    }
    
    public func substring(to: Int) -> String {
        let end = characters.index(startIndex, offsetBy: to)
        return String(self[..<end])
    }
    
    public func substring(from: Int, to: Int) -> String {
        guard from < to else {
            return ""
        }
        let start = index(startIndex, offsetBy: from)
        let end = index(startIndex, offsetBy: to)
        return String(self[start..<end])
    }
    
    public subscript (range: Range<Int>) -> String? {
        let count = characters.count
        
        //Check for out of boundary condition
        if count < range.upperBound || count < range.lowerBound { return nil }
        
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
    
    public func substring(nsRange range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    
    public func nsRangeOf(string: String) -> NSRange {
        return (self as NSString).range(of: string)
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    public func queryTokenizing() -> [String: String] {
        var result: [String:String] = [:]
        let tokens = characters.split(separator: "&").map(String.init)
        for token in tokens {
            if let index = token.characters.index(of: "=") {
                let key = String(token[..<index])
                let value = String(token[token.index(index, offsetBy: 1)...])
                result[key] = value
            }
        }
        return result
    }
    
    public func numberOfLines(size: CGSize, font: UIFont) -> Int {
        let storage = NSTextStorage(string: self, attributes: [NSAttributedStringKey.font: font])
        let container = NSTextContainer(size: size)
        container.lineBreakMode = .byWordWrapping
        container.maximumNumberOfLines = 0
        container.lineFragmentPadding = 0
        
        let manager = NSLayoutManager()
        manager.textStorage = storage
        manager.addTextContainer(container)
        
        var numberOfLines = 0
        var index = 0
        var lineRange = NSRange(location: 0, length: 0)
        
        while index < manager.numberOfGlyphs {
            manager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
    
}

public extension Data {
    
    public var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: count), count:count)
        return bytes
            .map { String(format: "%02hhx", $0) }
            .reduce("", { $0 + $1 })
    }
    
}

public extension Date {
    
    public static func date(kr_formatted string: String?, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        guard let string = string else {
            return nil
        }
        
        let dateFormatter = DateFormatter.kr_dateFormatter
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: string)
    }
    
}

public extension DateFormatter {
    
    public static var kr_dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 9)
        return dateFormatter
    }
    
}

public extension Calendar {
    
    public static var kr_calendar: Calendar {
        var calendar = Calendar.current
        let dateFormatter = DateFormatter.kr_dateFormatter
        calendar.locale = dateFormatter.locale
        calendar.timeZone = dateFormatter.timeZone
        return calendar
    }
    
}

public extension UserDefaults {
    
    public static func disableLayoutConstraintLog() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
}

public extension Bundle {
    
    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public static var buildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
}
