//
//  KofktuSDKTests.swift
//  KofktuSDKTests
//
//  Created by Kofktu on 2016. 7. 6..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import KofktuSDK

class KofktuSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure { 
            
        }
    }
    
    func test_dateFormatter() {
        let string = "2017-04-29 19:54:20"
        let dateFormatter = DateFormatter.kr_dateFormatter
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date.date(kr_formatted: string, dateFormat: "yyyy-MM-dd HH:mm:ss")
        
        XCTAssertNotNil(date)
        XCTAssertEqual(date, dateFormatter.date(from: string))
    }
    
    func test_substring() {
        let string = "가나다라마바사아"
        
        XCTAssertEqual(string.substring(from: 3), "라마바사아")
        XCTAssertEqual(string.substring(to: 3), "가나다")
        
        let range = string.nsRangeOf(string: "가나다")
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 3)
    }
    
    func test_formatted() {
        let intValue = 5000
        let floatValue = 5000.123
        let doubleValue = 5000.127
        
        XCTAssertEqual("5,000", intValue.formatted)
        XCTAssertEqual("5,000.123", floatValue.formatted)
        XCTAssertEqual("5,000.12", floatValue.formatted(fractionDigits: 2))
        XCTAssertEqual("5,000.127", doubleValue.formatted)
        XCTAssertEqual("5,000.13", doubleValue.formatted(fractionDigits: 2))
    }
    
    func test_userdefault_objectmapper() {
        let key = "ObjectMapper"
        let object = MapperObject(id: 10, value: "TEST")
        XCTAssertEqual(object.id, 10)
        XCTAssertEqual(object.value, "TEST")
        
        UserDefaults.standard.set(object: object, forKey: key)
        UserDefaults.standard.synchronize()
        
        let fromUserDefaultObject: MapperObject? = UserDefaults.standard.object(forKey: key)
        XCTAssertNotNil(fromUserDefaultObject)
        XCTAssertEqual(fromUserDefaultObject?.id, 10)
        XCTAssertEqual(fromUserDefaultObject?.value, "TEST")
    }
    
}

struct MapperObject: ImmutableMappable {
    
    private enum Keys {
        static let id = "id"
        static let value = "value"
    }
    
    var id: Int
    var value: String
    
    init(id: Int,
         value: String) {
        self.id = id
        self.value = value
    }
    
    init(map: Map) throws {
        id = try map.value(Keys.id)
        value = try map.value(Keys.value)
    }
    
    func mapping(map: Map) {
        id >>> map[Keys.id]
        value >>> map[Keys.value]
    }
    
}
