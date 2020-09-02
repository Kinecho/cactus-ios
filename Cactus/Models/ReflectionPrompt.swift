//
//  ReflectionPrompt.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class ReflectionPromptField: BaseModelField {
    static let question = "question"
    static let contentPath = "contentPath"
    static let sendDate = "sendDate"
    static let topic = "topic"
}

enum PromptType: String, Codable {
    case CACTUS
    case FREE_FORM
    
    static let customPromptTypes: [PromptType] = [.FREE_FORM]
    
    var isCustomPrompt: Bool {
        return PromptType.customPromptTypes.contains(self)
    }
}

class ReflectionPrompt: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.reflectionPrompt
    static let Field = ReflectionPromptField.self
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    var question: String?
    var contentPath: String?
    var sendDate: Date?
    var topic: String?
    var promptContentEntryId: String?
    
    // Custom Prompt fields
    var memberId: String?
    var promptType: PromptType = PromptType.CACTUS
    var sourceApp: AppType?
    
    static func == (lhs: ReflectionPrompt, rhs: ReflectionPrompt) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    var isCustomPrompt: Bool {
        return self.memberId != nil && self.promptType.isCustomPrompt
    }
    
    static func createFreeform(member: CactusMember) -> ReflectionPrompt {
        let p = ReflectionPrompt()
        p.memberId = member.id
        p.promptType = .FREE_FORM
        p.sourceApp = .IOS
        p.sendDate = Date()        
        return p
    }
}
