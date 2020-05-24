//
//  PromptContentTest.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 5/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class PromptContentTest: XCTestCase {
    func testGetDisplayText() throws {
        let textContentEmptyCV = Content()
        textContentEmptyCV.text = "Plain Text 1"
        let emptyCV = ContentCoreValues()
        emptyCV.textTemplateMd = " "
        
        textContentEmptyCV.coreValues = emptyCV
        
        let textContentWithCV = Content()
        textContentWithCV.text = "Plain Text 2"
        textContentWithCV.text_md = "MD Text 2"
        let cv1 = ContentCoreValues()
        
        cv1.textTemplateMd = "Template {{CORE_VALUE}}"
        textContentWithCV.coreValues = cv1
        
        
        let textContentNoCV = Content()
        textContentNoCV.text = "Plain Text 3"
        textContentNoCV.text_md = "MD 3"
        
        let reflectContent = Content()
        reflectContent.text = "Question Text"
        reflectContent.contentType = .reflect
        
        let promptContent = PromptContent()
        promptContent.content = [textContentNoCV, textContentWithCV, textContentEmptyCV, reflectContent]
        
        let cvMember = CactusMember()
        cvMember.coreValues = ["Security", "Altruism"]
        
        //Empty CV On content
        XCTAssertEqual(textContentEmptyCV.getDisplayText(), "Plain Text 1")
        XCTAssertEqual(textContentEmptyCV.getDisplayText(member: cvMember, preferredIndex: 0, coreValue: nil), "Plain Text 1")
        
        
        //No CV on content
        XCTAssertEqual(textContentNoCV.getDisplayText(), "MD 3")
        XCTAssertEqual(textContentNoCV.getDisplayText(member: cvMember, preferredIndex: 0, coreValue: nil), "MD 3")
        
        
        //has CV on content
        XCTAssertEqual(textContentWithCV.getDisplayText(), "MD Text 2")
        XCTAssertEqual(textContentWithCV.getDisplayText(member: cvMember, preferredIndex: 0, coreValue: nil), "Template Security")
        XCTAssertEqual(textContentWithCV.getDisplayText(member: cvMember, preferredIndex: 2, coreValue: nil), "Template Security")
        
        XCTAssertEqual(textContentWithCV.getDisplayText(member: cvMember, preferredIndex: 1, coreValue: nil), "Template Altruism")
        XCTAssertEqual(textContentWithCV.getDisplayText(member: cvMember, preferredIndex: 3, coreValue: nil), "Template Altruism")
        
        
        //question text
        XCTAssertEqual(promptContent.getDisplayableQuestion(), "Question Text")
    }


}
