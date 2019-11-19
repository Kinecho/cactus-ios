//
//  storageServiceTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 11/15/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest

class storageServiceTest: XCTestCase {
    private var userDefaults: UserDefaults!
    private var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        
        storageService = StorageService(userDefaults: userDefaults)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetQueryParams() {
        let params = ["first": "one", "second": "two"]
        
        XCTAssertNil(storageService.getLocalSignupQueryParams())
        
        storageService.setLocalSignupQueryParams(params)
        
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?.count == 2)
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?["first"] == "one")
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?["second"] == "two")
        
        let newParams = ["third": "three", "second": "edited"]
        
        storageService.setLocalSignupQueryParams(newParams)
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?.count == 3)
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?["first"] == "one")
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?["second"] == "two") // existing params should remain unaltered
        XCTAssertTrue(storageService.getLocalSignupQueryParams()?["third"] == "three")
        
    }
}
