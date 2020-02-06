//
//  Cactus_UnitTests.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 9/12/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class CactusUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringExtensions() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let initial = "Cactus is the best"
        let initialOrphaned = initial.preventOrphanedWords()
        XCTAssertEqual(initialOrphaned, "Cactus is the\u{00A0}best")
        let aInitial = NSAttributedString(string: initial)
        XCTAssertEqual(aInitial.preventOrphanedWords().string, initialOrphaned)        
    }

}
