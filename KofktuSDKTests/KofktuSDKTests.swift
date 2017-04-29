//
//  KofktuSDKTests.swift
//  KofktuSDKTests
//
//  Created by Kofktu on 2016. 7. 6..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import XCTest
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
    
    func test_logger() {
        Logger.isEnabled = true
        Log.style = [.debug, .info, .warning, .error]
        Log.d("Debug LOG")
        Log.w("Warning LOG")
        Log.i("Infomation LOG")
    }
}
