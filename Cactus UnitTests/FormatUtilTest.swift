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
    
    func testDateTimezoneFormat() {
        let tzName = "America/Denver"
        let isoDate = "2019-12-03T10:00:00+0000"

        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from:isoDate)!
        
        let tz = TimeZone(identifier: tzName)
        let locale = Locale.init(identifier: "en_US")        
        let standard = tz!.localizedName(for: .standard, locale: locale)
        let generic = tz!.localizedName(for: .generic, locale: locale)
        
        XCTAssertEqual(tz!.abbreviation(for: date), "MST")
        XCTAssertEqual(tz!.isDaylightSavingTime(for: date), false)
        XCTAssertEqual(standard!, "Mountain Standard Time")
        XCTAssertEqual(generic!, "Mountain Time")
        XCTAssertEqual(tz!.localizedName(for: .shortGeneric, locale: locale)!, "MT")
        XCTAssertEqual(tz!.localizedName(for: .shortStandard, locale: locale)!, "MST")
        XCTAssertEqual(tz!.localizedName(for: .daylightSaving, locale: locale)!, "Mountain Daylight Time")
        XCTAssertEqual(tz!.localizedName(for: .shortDaylightSaving, locale: locale)!, "MDT")
    }
    
    func testCurrencyFormat() {
        XCTAssertEqual(formatPriceCents(199), "$1.99")
        XCTAssertEqual(formatPriceCents(199, currencySymbol: ""), "1.99")
    }
    
    func testGetIntegerFromStringInRange() {
        XCTAssertEqual( getIntegerFromStringBetween(input: "abc", max: 5), 4)
        XCTAssertEqual( getIntegerFromStringBetween(input: "abc124", max: 5), 1)
        XCTAssertEqual( getIntegerFromStringBetween(input: "HumorNature", max: 5), 0)
        XCTAssertEqual( getIntegerFromStringBetween(input: "HumorNature", max: 8), 4)
        XCTAssertEqual( getIntegerFromStringBetween(input: "aaaa", max: 5), 3)
        XCTAssertEqual( getIntegerFromStringBetween(input: "a", max: 5), 2)
        XCTAssertEqual( getIntegerFromStringBetween(input: "b", max: 5), 3)
        XCTAssertEqual( getIntegerFromStringBetween(input: "c", max: 5), 4)
        XCTAssertEqual( getIntegerFromStringBetween(input: "d", max: 5), 0)
        XCTAssertEqual( getIntegerFromStringBetween(input: "", max: 5), 0)
    }
}
