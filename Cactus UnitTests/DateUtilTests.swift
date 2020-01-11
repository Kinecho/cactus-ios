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


}
