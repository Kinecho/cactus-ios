//
//  SentPrompt.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class SentPromptField:BaseModelField {
    static let promptId = "promptId"
    static let userId = "userId"
    static let cactusMemberId = "cactusMemberId"
    static let firstSentAt = "firstSentAt"
    static let lastSentAt = "lastSentAt"
}

class SentPrompt:FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.sentPrompts
    static let Field = SentPromptField.self
    var promptId:String?
    var userId:String?
    var cactusMemberId:String?
    var lastSentAt: Date?
    var firstSentAt: Date?
    var memberEmail: String?
    var id : String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    
    static func == (lhs: SentPrompt, rhs: SentPrompt) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher){
        id.hash(into: &hasher)
    }
}
