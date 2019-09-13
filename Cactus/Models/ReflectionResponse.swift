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
    var content = ReflectionContent()
    var promptId: String?
    var promptQuestion: String?
    var promptContentEntryId: String?
    
    static func == (lhs: ReflectionResponse, rhs: ReflectionResponse) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
