//
//  Extensions.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation
import ObjectMapper

public extension IntegerLiteralType {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? String(self)
    }
    
    func formatted(fractionDigits: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(for: self) ?? String(self)
    }
}

public extension FloatLiteralType {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? String(self)
    }
    
    func formatted(fractionDigits: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(for: self) ?? String(self)
    }
    
}

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

public extension Dictionary {
    
    mutating func merge(dict: [Key: Value]) {
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
    
}

public extension String {
    
    var urlEncoded: String? {
        let characterSet = NSCharacterSet(charactersIn: "\n ;:\\@&=+$,/?%#[]|\"<>").inverted
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
    
    var urlDecoded: String? {
        return removingPercentEncoding
    }
    
    var base64Encoded: String? {
        return data(using: .utf8, allowLossyConversion: true)?.base64EncodedString(options: [])
    }
    
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return NSString(format: format, arguments: getVaList(args)) as String
    }
    
    var ns: NSString {
        return self  as NSString
    }
    
    func indexOf(string: String) -> Int? {
        guard let range = range(of: string) else { return nil }
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    // for convenience we should include String return
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)
        
        return String(self[start...end])
    }
    
    func substring(from: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        return String(self[start...])
    }
    
    func substring(to: Int) -> String {
        let end = index(startIndex, offsetBy: to)
        return String(self[..<end])
    }
    
    func substring(from: Int, to: Int) -> String {
        guard from < to else {
            return ""
        }
        let start = index(startIndex, offsetBy: from)
        let end = index(startIndex, offsetBy: to)
        return String(self[start..<end])
    }
    
    subscript (range: Range<Int>) -> String? {
        //Check for out of boundary condition
        if count < range.upperBound || count < range.lowerBound { return nil }
        
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
    
    func substring(nsRange range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    
    func nsRangeOf(string: String) -> NSRange {
        return (self as NSString).range(of: string)
    }
    
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func queryTokenizing() -> [String: String] {
        var result: [String:String] = [:]
        let tokens = split(separator: "&").map(String.init)
        for token in tokens {
            if let index = token.firstIndex(of: "=") {
                let key = String(token[..<index])
                let value = String(token[token.index(index, offsetBy: 1)...])
                result[key] = value
            }
        }
        return result
    }
    
    func numberOfLines(size: CGSize, font: UIFont) -> Int {
        let storage = NSTextStorage(string: self, attributes: [NSAttributedString.Key.font: font])
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
    
    func boundingRect(with size: CGSize, attributes: [NSAttributedString.Key: Any]) -> CGRect {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = self.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return snap(rect)
    }
    
    func size(thatFits size: CGSize, font: UIFont, maximumNumberOfLines: Int = 0) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        var size = self.boundingRect(with: size, attributes: attributes).size
        if maximumNumberOfLines > 0 {
            size.height = min(size.height, CGFloat(maximumNumberOfLines) * font.lineHeight)
        }
        return size
    }
    
    func width(with font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).width
    }
    
    func height(thatFitsWidth width: CGFloat, font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).height
    }
    
}

public extension Data {
    
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: count), count:count)
        return bytes
            .map { String(format: "%02hhx", $0) }
            .reduce("", { $0 + $1 })
    }
    
}

public extension Date {
    
    var betweenNow: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int)? {
        let components = Calendar.kr_calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                            from: self,
                                                            to: Date())
        
        guard let year = components.year,
            let month = components.month,
            let day = components.day,
            let hour = components.hour,
            let minute = components.minute,
            let second = components.second else {
            return nil
        }
        
        return (year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    static func date(kr_formatted string: String?, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        guard let string = string else {
            return nil
        }
        
        let dateFormatter = DateFormatter.kr_dateFormatter
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: string)
    }
    
}

public extension DateFormatter {
    
    static var kr_dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 9)
        return dateFormatter
    }
    
}

public extension Calendar {
    
    static var kr_calendar: Calendar {
        var calendar = Calendar.current
        let dateFormatter = DateFormatter.kr_dateFormatter
        calendar.locale = dateFormatter.locale
        return calendar
    }
    
}

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

public extension Bundle {
    
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var buildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
}
