//
//  ReflectionResponseTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 11/19/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class ReflectionResponseTest: XCTestCase {

    func testAddDateLog() {
        let threshold = 10
        let model = ReflectionResponse()
        XCTAssertNil(model.reflectionDates)
        let d1 = Date()
        let added1 = model.addReflectionLog(d1, thresholdInMinutes: threshold)
        XCTAssertTrue(added1)
        XCTAssertEqual(model.reflectionDates?.count, 1)
        
        let added2 = model.addReflectionLog(d1, thresholdInMinutes: threshold)
        XCTAssertFalse(added2)
        XCTAssertEqual(model.reflectionDates?.count, 1)
        
        
        let d2 = d1.addingTimeInterval(TimeInterval(threshold + 1) * 60)
        let added3 = model.addReflectionLog(d2, thresholdInMinutes: threshold)
        XCTAssertTrue(added3)
        XCTAssertEqual(model.reflectionDates?.count, 2)
        
        let d3 = d1.addingTimeInterval(TimeInterval(threshold + 1) * -60)
        let added4 = model.addReflectionLog(d3, thresholdInMinutes: threshold)
        XCTAssertTrue(added4)
        XCTAssertEqual(model.reflectionDates?.count, 3)
    }

    

}
