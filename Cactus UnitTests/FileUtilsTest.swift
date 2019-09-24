//
//  FileUtilsTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import XCTest
//import Firebase
//@testable import Cactus_Stage

class FileUtilsTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testIsGif(){
        XCTAssertTrue(FileUtils.isGif("https://google.com/image.gif"))
        XCTAssertFalse(FileUtils.isGif(nil))
        XCTAssertFalse(FileUtils.isGif("https://google.com"))
        XCTAssertFalse(FileUtils.isGif("https://google.com/image.png"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
