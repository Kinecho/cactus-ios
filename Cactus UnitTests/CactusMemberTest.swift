//
//  CactusMemberTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 5/22/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class CactusMemberTest: XCTestCase {

    func testGetCoreValue() throws {
        let member = CactusMember()
        member.coreValues = ["Abundance", "Accomplishment", "Achievement"]
        
        XCTAssertEqual(member.getCoreValue(), "Abundance")
        XCTAssertEqual(member.getCoreValue(at: 0), "Abundance")
        XCTAssertEqual(member.getCoreValue(at: 1), "Accomplishment")
        XCTAssertEqual(member.getCoreValue(at: 2), "Achievement")
        
        XCTAssertEqual(member.getCoreValue(at: 3), "Abundance")
        XCTAssertEqual(member.getCoreValue(at: 4), "Accomplishment")
        XCTAssertEqual(member.getCoreValue(at: 5), "Achievement")
        
        XCTAssertEqual(member.getCoreValue(at: 6), "Abundance")
        XCTAssertEqual(member.getCoreValue(at: 7), "Accomplishment")
        XCTAssertEqual(member.getCoreValue(at: 8), "Achievement")
    }
    
    func testGetCoreValueNoValuesPresent() throws {
        let member = CactusMember()
        member.coreValues = nil
        XCTAssertNil(member.getCoreValue())
        XCTAssertNil(member.getCoreValue(at: 1))
        XCTAssertNil(member.getCoreValue(at: 2))
        XCTAssertNil(member.getCoreValue(at: 99))
        
        member.coreValues = []
        XCTAssertNil(member.getCoreValue())
        XCTAssertNil(member.getCoreValue(at: 1))
        XCTAssertNil(member.getCoreValue(at: 2))
        XCTAssertNil(member.getCoreValue(at: 99))
    }

}
