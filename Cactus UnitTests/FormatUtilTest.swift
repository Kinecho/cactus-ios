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

    func wrapInQuotesTest() {
        XCTAssertEqual(FormatUtils.wrapInDoubleQuotes(input: "test"), "\"test\"")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
