//
//  CactusColorTests.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 8/5/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class CactusColorTests: XCTestCase {

    func testAllColorsExist() throws {
        XCTAssertNoThrow( NamedColor.allCases.forEach({ print($0.uiColor) }) )
    }

}
