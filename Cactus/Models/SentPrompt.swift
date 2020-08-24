//
//  SentPrompt.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

enum PromptSendMedium: String, Codable {
    case EMAIL_MAILCHIMP
    case EMAIL_SENDGRID
    case PROMPT_CONTENT
    case FREE_FORM
    case CRON_JOB
    case CUSTOM_SENT_PROMPT_TIME
    case PUSH
}

class SentPromptField: BaseModelField {
    static let promptId = "promptId"
    static let userId = "userId"
    static let cactusMemberId = "cactusMemberId"
    static let firstSentAt = "firstSentAt"
    static let lastSentAt = "lastSentAt"
    static let completed = "completed"
    static let completedAt = "completedAt"
}

class SentPrompt: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.sentPrompts
    static let Field = SentPromptField.self
    var promptId: String?
    var userId: String?
    var cactusMemberId: String?
    var lastSentAt: Date?
    var firstSentAt: Date?
    var memberEmail: String?
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var completed: Bool? = false
    var completedAt: Date?
    var promptType: PromptType? = PromptType.CACTUS
    var medium: PromptSendMedium?
    
    static func == (lhs: SentPrompt, rhs: SentPrompt) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    static func createId(memberId: String, promptId: String) -> String {
        return "\(memberId)_\(promptId)"
    }
    
    static func createFreeform(prompt: ReflectionPrompt, member: CactusMember) -> SentPrompt? {
        guard let memberId = member.id, let promptId = prompt.id else {
            return nil
        }
        let sentPrompt = SentPrompt()
        sentPrompt.cactusMemberId = member.id
        sentPrompt.id = SentPrompt.createId(memberId: memberId, promptId: promptId)
        sentPrompt.promptType = .FREE_FORM
        sentPrompt.firstSentAt = Date()
        sentPrompt.lastSentAt = Date()
        sentPrompt.memberEmail = member.email
        sentPrompt.userId = member.userId
        sentPrompt.medium = .FREE_FORM
        sentPrompt.completed = true
        sentPrompt.completedAt = Date()
        
        return sentPrompt
    }
}
