//
//  ModelType.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 5. 7..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol ModelType: Mappable {}
public protocol ImmutableModelTypes: ImmutableMappable {}

final public class IntToStringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = Int
    
    public init() {
    }
    
    public func transformFromJSON(_ value: Any?) -> String? {
        guard let intValue = value as? Int else { return nil }
        return String(intValue)
    }
    
    public func transformToJSON(_ value: String?) -> Int? {
        return value.flatMap { Int($0) }
    }
}

final public class StringNullTransform: TransformType {
    public typealias Object = String
    public typealias JSON = String
    
    public init() {
    }
    
    public func transformFromJSON(_ value: Any?) -> String? {
        guard let value = value as? String, !value.trim().isEmpty else {
            return nil
        }
        return value
    }
    
    public func transformToJSON(_ value: String?) -> String? {
        return value
    }
}

final public class StringEscpeTransform: TransformType {
    public typealias Object = String
    public typealias JSON = String
    
    public init() {
    }
    
    public func transformFromJSON(_ value: Any?) -> String? {
        return (value as? String)?
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }
    
    public func transformToJSON(_ value: String?) -> String? {
        return value
    }
}

public enum KRDateTransformDateFormat: String {
    case `default` = "yyyy-MM-dd'T'HH:mm:ssZ"
    case krTimeZone = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case clien = "yyyy-MM-dd HH:mm:ss"
    case ou = "yy/MM/dd HH:mm"
}

final public class KRDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    private var dateFormat: String
    
    public init(format: String = KRDateTransformDateFormat.default.rawValue) {
        dateFormat = format
    }
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        guard let value = value as? String else { return nil }
        let dateFormatter = DateFormatter.kr_dateFormatter
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: value)
    }
    
    public func transformToJSON(_ value: Date?) -> String? {
        guard let value = value else { return nil }
        let dateFormatter = DateFormatter.kr_dateFormatter
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: value)
    }
}

extension KRDateTransform {
    convenience public init(dateFormat format: KRDateTransformDateFormat = .default) {
        self.init(format: format.rawValue)
    }
}

final public class TimeIntervalTransform: TransformType {
    public typealias Object = TimeInterval
    public typealias JSON = TimeInterval
    
    public init() {
    }
    
    public func transformFromJSON(_ value: Any?) -> TimeInterval? {
        guard let value = value as? TimeInterval else {
            return nil
        }
        return value / 1000.0
    }
    
    public func transformToJSON(_ value: TimeInterval?) -> TimeInterval? {
        guard let value = value else {
            return nil
        }
        return value * 1000.0
    }
}

final public class TimeIntervalToDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = TimeInterval
    
    public init() {
    }
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        guard let value = value as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: value / 1000.0)
    }
    
    public func transformToJSON(_ value: Date?) -> TimeInterval? {
        return value.flatMap { $0.timeIntervalSince1970 * 1000.0 }
    }
}
