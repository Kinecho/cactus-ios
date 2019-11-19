//
//  URLExtensionTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 11/15/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class URLExtensionTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetQueryParams() {
        XCTAssertTrue(URL(string: "https://cactus.app?param=one&other=two")!.getQueryParams()["param"] == "one")
        XCTAssertTrue(URL(string: "https://cactus.app?param=one&other=two")!.getQueryParams()["other"] == "two")
        XCTAssertTrue(URL(string: "https://cactus.app?param=one&other=two")!.getQueryParams().count == 2)
        XCTAssertTrue(URL(string: "https://cactus.app")!.getQueryParams().count == 0)
    }
    
    func testGetPathId() {
        XCTAssertEqual(URL(string: "https://cactus.app/this/reflection/abc123/test")!.getPathId(for: "reflection"), "abc123")
        XCTAssertNil(URL(string: "https://cactus.app/this/reflection/abc123/test")!.getPathId(for: "test"))
        XCTAssertEqual(URL(string: "https://cactus-app-stage.web.app/prompts/IAOrt4jq7sXilcpyprdG?slide=0")!.getPathId(for: "prompts"), "IAOrt4jq7sXilcpyprdG")
    }
}
