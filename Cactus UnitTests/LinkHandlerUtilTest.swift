//
//  LinkHandlerUtilTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 11/14/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class LinkHandlerUtilTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetLinkPath() {
        XCTAssertEqual(LinkHandlerUtil.getPath("https://cactus.app/this/is/a/test"), "/this/is/a/test")
        XCTAssertEqual(LinkHandlerUtil.getPath("https://cactus.app/this/is/a/test?query=one"), "/this/is/a/test")
    }
    
    func testGetPathId() {
        XCTAssertEqual(LinkHandlerUtil.getPathId("https://cactus.app/this/reflection/abc123/test", for: "reflection"), "abc123")
        XCTAssertNil(LinkHandlerUtil.getPathId("https://cactus.app/this/reflection/abc123/test", for: "test"))
        XCTAssertEqual(LinkHandlerUtil.getPathId("https://cactus-app-stage.web.app/prompts/IAOrt4jq7sXilcpyprdG?slide=0", for: "prompts"), "IAOrt4jq7sXilcpyprdG")
    }
}
