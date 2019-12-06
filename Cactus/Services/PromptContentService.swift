//
//  PromptContentService.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class PromptContentService {
    let flamelinkService: FlamelinkService
    let logger = Logger("PromptContentService")
    let schema = FlamelinkSchema.promptContent
    
    static let sharedInstance = PromptContentService()
    
    private init() {
        self.flamelinkService = FlamelinkService.sharedInstance
    }
    
    func getBaseQuery() -> Query {
        return self.flamelinkService.getQuery(FlamelinkSchema.promptContent)
    }
    
    func getByEntryId(id: String, _ onData: @escaping (PromptContent?, Any?) -> Void) {
        flamelinkService.getByEntryId(id, schema: self.schema) { (promptContent: PromptContent?, error) in
            self.logger.debug("Fetched prompt content for entryId \(id)")
            if let error = error {
                self.logger.error("Failed to fetch prompt content", error)
            }
            onData(promptContent, error)
        }
    }
    
    func getByPromptId(promptId: String, _ onData: @escaping (PromptContent?, Any?) -> Void) {
        let query = self.flamelinkService.getQuery(PromptContent.schema).whereField("promptId", isEqualTo: promptId)
        self.flamelinkService.getFirst(query, onData)
    }
    
    func observeForPromptId(promptId: String, _ onData: @escaping (PromptContent?, Any?) -> Void) -> ListenerRegistration {
        let query = self.flamelinkService.getQuery(PromptContent.schema).whereField("promptId", isEqualTo: promptId)
        return flamelinkService.addListener(query) { (promptContentItems, error) in
            onData(promptContentItems?.first, error)
        }
    }
}
