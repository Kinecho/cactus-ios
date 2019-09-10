//
//  ReflectionPrompt.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation


//
//  SentPrompt.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class ReflectionPromptField:BaseModelField {
    static let question = "question"
    static let contentPath = "contentPath"
    static let sendDate = "sendDate"
    static let topic = "topic"
}

class ReflectionPrompt:FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.reflectionPrompt
    static let Field = ReflectionPromptField.self
    var id : String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    var question:String?
    var contentPath:String?
    var sendDate:Date?
    var topic:String?
    var promptContentEntryId:String?
    
    static func == (lhs: ReflectionPrompt, rhs: ReflectionPrompt) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher){
        id.hash(into: &hasher)
    }
}
