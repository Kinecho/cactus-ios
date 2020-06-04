//
//  StringExtensionsTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 6/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class StringExtensionsTest: XCTestCase {

    func testPreventOprphanedWordsString() throws {
        let string = "Today you’ll focus on how you show yourself kindness when experiencing negative emotions."
        let transformed = string.preventOrphanedWords()
        XCTAssertEqual(transformed, "Today you’ll focus on how you show yourself kindness when experiencing negative\u{00A0}emotions.")
        
        let t2 = transformed.preventOrphanedWords()
        XCTAssertEqual(t2, "Today you’ll focus on how you show yourself kindness when experiencing negative\u{00A0}emotions.")
    }

//Couldn't get this test to work as I wanted, not sure what the solution is.
//    func testPreventOprphanedWordsAttributedString() throws {
//        let string = "Today you’ll focus on how you show yourself kindness when experiencing negative emotions."
//        let as1 = NSAttributedString(string: string)
//
//
//        XCTAssertEqual(as1.string, "Today you’ll focus on how you show yourself kindness when experiencing negative emotions.")
//        XCTAssertEqual(as1, NSAttributedString(string: "Today you’ll focus on how you show yourself kindness when experiencing negative emotions."))
//
//        let transformed = as1.preventOrphanedWords()
//        print("transformed = \(transformed.string)")
//        XCTAssertEqual(transformed, NSAttributedString(string: "Today you’ll focus on how you show yourself kindness when experiencing negative\u{00A0}emotions."))
//        XCTAssertEqual(transformed.string, "Today you’ll focus on how you show yourself kindness when experiencing negative\u{00A0}emotions.")
//
//        let t2 = transformed.preventOrphanedWords()
//        XCTAssertEqual(t2.string, "Today you’ll focus on how you show yourself kindness when experiencing negative\u{00A0}emotions.")
//    }
}
