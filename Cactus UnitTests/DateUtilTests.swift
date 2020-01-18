//
//  DateUtilTests.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 1/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class DateUtilTests: XCTestCase {

    func testFlamelinkDateFormat() {
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.day = 10
        components.hour = 22
        components.minute = 8
        components.second = 22
        components.nanosecond = 200500
        
        let dateInput = Calendar.current.date(from: components)
        XCTAssertEqual(getFlamelinkDateStringAtMidnight(for: dateInput!), "2020-01-10T00:00")
    }

    func getActivityDates(difference: Int) -> (activity: Date, current: Date) {
        let activityDate = Date()
        let current = Calendar.current.date(byAdding: Calendar.Component.second, value: difference, to: activityDate)!
        return (activityDate, current)
    }
    
    func getDuration(_ seconds: Int) -> String? {
        let one = getActivityDates(difference: seconds)
        return formatDuaration(one.activity, one.current)
    }
    
    func testFormatDuration() {
        XCTAssertEqual(getDuration(90), "2 minutes")
        XCTAssertEqual(getDuration(50), "50 seconds")
        XCTAssertEqual(getDuration(60), "1 minute")
        XCTAssertEqual(getDuration(345600), "4 days")
        XCTAssertEqual(getDuration(60 * 9 + 20), "9 minutes")
    }
    
}
