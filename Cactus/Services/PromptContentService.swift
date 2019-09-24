//
//  PromptContentService.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

class PromptContentService {
    let flamelinkService: FlamelinkService
    
    let schema = FlamelinkSchema.promptContent
    
    static let sharedInstance = PromptContentService()
    
    private init() {
        self.flamelinkService = FlamelinkService.sharedInstance
    }
    
    func getByEntryId(id: String, _ onData: @escaping (PromptContent?, Any?) -> Void) {
        flamelinkService.getByEntryId(id, schema: self.schema) { (promptContent: PromptContent?, error) in
            print("Fetched prompt content")
            if let error = error {
                print("Failed to fetch prompt content", error)
            }
            onData(promptContent, error)
        }
    }
}
