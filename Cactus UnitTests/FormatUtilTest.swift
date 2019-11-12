//
//  FormatUtilTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 10/7/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class FormatUtilTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrapInQuotes() {
        XCTAssertEqual(FormatUtils.wrapInDoubleQuotes(input: "test"), "\"test\"")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testHasChanges() {
        XCTAssertTrue(FormatUtils.hasChanges(nil, "new value"))
        XCTAssertTrue(FormatUtils.hasChanges("old value", "new value"))
        XCTAssertTrue(FormatUtils.hasChanges("old value", nil))
        XCTAssertTrue(FormatUtils.hasChanges("old value", ""))
        XCTAssertFalse(FormatUtils.hasChanges(nil, ""))
        XCTAssertFalse(FormatUtils.hasChanges(nil, nil))
        XCTAssertFalse(FormatUtils.hasChanges("", ""))
        XCTAssertFalse(FormatUtils.hasChanges(nil, " "))
        
    }

}
