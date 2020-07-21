//
//  MockData.swift
//  Cactus
//
//  Created by Neil Poulin on 7/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

struct MockData {
    static func content(_ text: String, _ contentType: ContentType = .reflect) -> Content {
        let content = Content()
        content.contentType = contentType
        content.text = text
        return content
    }
    
    static func promptContent(id: String, content: [Content]) -> PromptContent {
        let prompt = PromptContent()
        prompt.entryId = id
        prompt.content = content
        return prompt
    }
    
    static func journalEntry(id: String, content: [Content]=[], loaded: Bool=true) -> JournalEntry {
        var entry = JournalEntry(promptId: id)
        
        entry.promptContent = self.promptContent(id: id, content: content)
        entry.loadingComplete = loaded
        return entry
    }
}

