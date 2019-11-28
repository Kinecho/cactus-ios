//
//  SharingServiceTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 11/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class SharingServiceTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testActivityTypeDisplayName() {
        XCTAssertEqual(getShareActivityTypeDisplayName(UIActivity.ActivityType("com.apple.reminders.sharingextension")), "com.apple.reminders.sharingextension")
        XCTAssertEqual(getShareActivityTypeDisplayName(UIActivity.ActivityType.postToFacebook), "Post to Facebook")
    }

}
