//
//  Date+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

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
