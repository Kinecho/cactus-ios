//
//  ReflectionResponse.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class ReflectionResponseField: BaseModelField {
    static let question = "question"
    static let contentPath = "contentPath"
    static let sendDate = "sendDate"
    static let topic = "topic"
    static let userId = "userId"
    static let cactusMemberId = "cactusMemberId"
    static let responseDate = "responseDate"
    static let emailReplyId = "emailReplyId"
    static let responseMedium = "responseMedium"
    static let mailchimpMemberId = "mailchimpMemberId"
    static let mailchimpUniqueEmailId = "mailchimpUniqueEmailId"
    static let memberEmail = "memberEmail"
    static let content = "content"
    static let promptId = "promptId"
    static let promptQuestion = "promptQuestion"
    static let promptContentEntryId = "promptContentEntryId"
}

public enum ResponseMedium: String, Codable {
    case EMAIL
    case JOURNAL_WEB
    case JOURNAL_IOS
    case JOURNAL_ANDROID
    case PROMPT_WEB
    case PROMPT_IOS
    case PROMPT_ANDROID
}

struct ReflectionContent: Codable {
    var text: String?
}

class ReflectionResponse: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.reflectionResponses
    static let Field = ReflectionResponseField.self
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    var userId: String?
    var cactusMemberId: String?
    var responseDate: Date?
    var emailReplyId: String?
    var responseMedium: ResponseMedium?
    var mailchimpMemberId: String?
    var mailchimpUniqueEmailId: String?
    var memberEmail: String?
    var memberFirstName: String?
    var memberLastName: String?
    var content = ReflectionContent()
    var promptId: String?
    var promptQuestion: String?
    var promptContentEntryId: String?
    var reflectionDurationMs: Int?
    var cactusElement: CactusElement?
    var reflectionDates: [Date]?
    var shared: Bool? = false
    var sharedAt: Date?
    var unsharedAt: Date?
    
    static func == (lhs: ReflectionResponse, rhs: ReflectionResponse) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    /**
        Add a date to the reflection date array.
        - Parameter date: The date to add
        - Parameter thresholdInMinutes: The threshold to use to determine if a new date should be added to the array or not.
        - Returns: If the new date was added or not
     */
    func addReflectionLog(_ date: Date, thresholdInMinutes: Int = 10) -> Bool {
        if self.reflectionDates == nil {
            self.reflectionDates = []
        }
        
        let hasRecent = self.reflectionDates?.contains(where: { (d) -> Bool in
            return Int(abs(d.timeIntervalSince(date))) < (thresholdInMinutes * 60)
        })
        if hasRecent == true {
            return false
        }
        self.reflectionDates?.append(date)
        
        return true
    }
    
    /**
     Get the full name of the member that reflected. Uses the firstName and lastname when available.
     - Returns: String or nil. String value is trimmed of whitespaces
     */
    func getFullName() -> String? {
        let name = "\(self.memberFirstName ?? "") \(self.memberLastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        return FormatUtils.isBlank(name) ? nil : name
    }
    
    func getFullNameOrEmail() -> String? {
        let name = self.getFullName()
        if !FormatUtils.isBlank(name) {
            return name
        }
        return self.memberEmail
    }
}
