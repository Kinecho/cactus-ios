//
//  LocalizationTests.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class LocalizationTests: XCTestCase {

    func testNumberOfDays() throws {
        XCTAssertEqual(StringDictKey.numberOfDays.formatted(0), "0 days")
        XCTAssertEqual(StringDictKey.numberOfDays.formatted(1), "1 day")
        XCTAssertEqual(StringDictKey.numberOfDays.formatted(2), "2 days")
        
        XCTAssertEqual(LocalizedText.numberOfDays(0).string, "0 days")
        XCTAssertEqual(LocalizedText.numberOfDays(1).string, "1 day")
        XCTAssertEqual(LocalizedText.numberOfDays(2).string, "2 days")
        XCTAssertEqual(LocalizedText.numberOfDays(3).string, "3 days")
    }

    func testNumberOfMinutes() throws {
        XCTAssertEqual(LocalizedText.numberOfDays(0).string, "0 days")
        XCTAssertEqual(LocalizedText.numberOfDays(1).string, "1 day")
        XCTAssertEqual(LocalizedText.numberOfDays(2).string, "2 days")
        XCTAssertEqual(LocalizedText.numberOfDays(3).string, "3 days")
    }
    
    func testCactusString() throws {
        XCTAssertEqual(NSLocalizedString("Cactus", comment: ""), "Cactus")
        XCTAssertEqual(LocalizedText(.Cactus).string, "Cactus")
    }
    
    func testLocalizedUnit() throws {
        XCTAssertEqual(LocalizedUnit.day(2).string, "2 days")
        XCTAssertEqual(LocalizedUnit.day(1).string, "1 day")
        
        XCTAssertEqual(LocalizedUnit.minute(2).string, "2 minutes")
        XCTAssertEqual(LocalizedUnit.minute(1).string, "1 minute")
        
        XCTAssertEqual(LocalizedUnit.minute(1).unitsOnly, "minute")
        XCTAssertEqual(LocalizedUnit.minute(2).unitsOnly, "minutes")
        
        XCTAssertEqual(LocalizedUnit.day(1).unitsOnly, "day")
        XCTAssertEqual(LocalizedUnit.day(2).unitsOnly, "days")
    }

}
