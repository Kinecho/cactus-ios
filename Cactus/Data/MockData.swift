//
//  MockData.swift
//  Cactus
//
//  Created by Neil Poulin on 7/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

let blobUrls: [String] = [
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200507.png?alt=media&token=ed3d7256-81a6-4bdd-bb57-16991c284e47",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200707.png?alt=media&token=3ff817ca-f58f-457a-aff0-bbefebb095ad",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200705.png?alt=media&token=6c66459d-52b1-41a7-a400-0c040a4c391a",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F2006201.G6OUznQhWomOHO7fXhqq.png?alt=media&token=4b85cb7c-936c-4848-a149-c7f7c20dde13",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200609.png?alt=media&token=cb746c6c-8eff-48db-ac0e-78f416911884",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2Fonboard4.png?alt=media&token=44045a9c-1e23-4ab9-8d4a-ec8e57e75576",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200601.png?alt=media&token=2ce39b4b-1183-443b-80b8-279d669df99a",
    "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200528.cKnJYkVwSHsM9ZoWGWwN.png?alt=media&token=6b9a3d70-04ce-4322-9f56-ec500367f254",
]

struct MockData {
    static func content(_ text: String?, _ contentType: ContentType = .reflect, backgroundImage: String?=nil, photo: String?=nil) -> Content {
        let content = Content()
        content.contentType = contentType
        content.text = text
        
        if let backgroundImage = backgroundImage {
            let img = ContentBackgroundImage(storageUrl: backgroundImage)
            content.backgroundImage = img
        }
        
        if let photo = photo {
            let img = ContentBackgroundImage(storageUrl: photo)
            content.photo = img
        }
        
        return content
    }
    
    static func getDefaultJournalEntries() -> [JournalEntry] {
        return [
            MockData.getUnansweredEntry(isToday: true, blob: 0),
            MockData.getAnsweredEntry(blob: 1),
            MockData.getUnansweredEntry(isToday: false, blob: 2),
            MockData.EntryBuilder(question: "What do you think of SwiftUI?", answer: "This is a really thoughtful response.", blob: 3).build(),
            MockData.getLoadingEntry(),
        ]
    }
    
    static func getBlobImage(_ at: Int) -> String {
        let index = at % (blobUrls.count - 1)
        return blobUrls[index]
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
    
    static func EntryBuilder(question: String?, answer: String?, promptId: String=UUID().uuidString, memberId: String="m1", blob: Int?=nil) -> JournalEntry.Builder {
        let contentBuilder = PromptContent.Builder(promptId)
        
        
        if let blob = blob {
            contentBuilder.addContent(answer, .text, backgroundBlob: blob)
        } else {
            contentBuilder.addContent(answer, .text)
        }
        
        let builder = JournalEntry.Builder(promptId)
            .setAllLoaded(true)
            .setPrompt(ReflectionPrompt.Builder(promptId)
                .setQuestion(question)
                .build())
            .setPromptContent(contentBuilder.build())
            .setSentPrompt(SentPrompt.Builder(promptId: promptId, memberId: memberId)
                .setCompleted(answer != nil)
                .setFirstSentAt("2020-07-12")
                .build())
                
        if let answer = answer {
            _ = builder.addResponse(ReflectionResponse.Builder(promptId)
                .setQuestion(question)
                .setText(answer)
                .setReflectionDate(Date())
                .build())
        }
        
        return builder
    }
    
    static func getLoadingEntry(blob: Int?=nil) -> JournalEntry {
        return MockData.EntryBuilder(question: "How come stuff loads for so long?", answer: nil, blob: blob)
            .setAllLoaded(false)
            .build()
        
    }
    
    static func getUnansweredEntry(isToday: Bool=false, blob: Int?=nil) -> JournalEntry {
        let builder = MockData.EntryBuilder(question: "How do you overcome **failure**?", answer: nil, blob: blob)
            .setAllLoaded(true)
            .prependContent(Content.Builder()
                .setText("Today you'll focus on how you conquer difficult challenges and failure.")
                .setType(.text)
                .setBackgroundImage(blob: 0)
                .build())
            .setTodaysPrompt(isToday)
        
        return builder.build()
    }
    
    static func getAnsweredEntry(isToday: Bool=false, blob: Int?=nil) -> JournalEntry {
        let builder = MockData.EntryBuilder(question: "How do you overcome **failure**?", answer: "I am going to reflect on the things that make me happy. Using Cactus will help me overcome a lot of bad things!", blob: blob)
            .setAllLoaded(true)
            .prependContent(MockData.content("Today you'll focus on how you conquer difficult challenges and failure.", .text, backgroundImage: "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200707.png?alt=media&token=3ff817ca-f58f-457a-aff0-bbefebb095ad"))
            .setTodaysPrompt(isToday)
        
        return builder.build()
    }
    
}

extension JournalEntry {
    public class Builder {
        var entry: JournalEntry
        
        init(_ promptId: String?=UUID().uuidString) {
            self.entry = JournalEntry(promptId: promptId)
        }
        
        func setPromptContent(_ pc: PromptContent?) -> Builder {
            self.entry.promptContent = pc
            return self
        }
        
        func setPrompt(_ p: ReflectionPrompt?) -> Builder {
            self.entry.prompt = p
            if p?.id == nil {
                p!.id = self.entry.promptId
            }
            return self
        }
        
        func setSentPrompt(_ sp: SentPrompt?) -> Builder {
            self.entry.sentPrompt = sp
            return self
        }
        
        func addResponse(_ r: ReflectionResponse, loaded: Bool=true) -> Builder {
            var responses = self.entry.responses ?? []
                        
            responses.append(r)
            r.promptId = self.entry.promptId
            if r.promptQuestion == nil {
                r.promptQuestion = self.entry.prompt?.question ?? self.entry.promptContent?.getQuestion()
            }
            self.entry.responses = responses
            self.entry.responsesLoaded = loaded
            return self
        }
        
        func setAllLoaded(_ loaded: Bool) -> Builder {
            self.entry.loadingComplete = loaded
            self.entry.promptContentLoaded = loaded
            self.entry.responsesLoaded = loaded
            self.entry.promptLoaded = loaded
            return self
        }
        
        func appendContent(_ content: Content) -> Builder {
            self.entry.promptContent?.content.append(content)
            return self
        }
        
        func prependContent(_ content: Content, index: Int=0) -> Builder {
            self.entry.promptContent?.content.insert(content, at: index)
            return self
        }
        
        func setTodaysPrompt(_ isToday: Bool) -> Builder {
            self.entry.isTodaysPrompt = isToday
            return self
        }
        
        func build() -> JournalEntry {
            return self.entry
        }
    }
}

extension SentPrompt {
    public class Builder {
        var sentPrompt: SentPrompt
        
        init(promptId: String, memberId: String) {
            self.sentPrompt = SentPrompt()
            self.sentPrompt.promptId = promptId
            self.sentPrompt.cactusMemberId = memberId
            self.sentPrompt.id = "\(memberId)_\(promptId)"
            _ = self.setFirstSentAt(Date())
        }
        
        func setFirstSentAt(_ d: Date) -> Builder {
            self.sentPrompt.firstSentAt = d
            return self
        }
        
        func setFirstSentAt(_ input: String, format: String?=nil) -> Builder {
            self.sentPrompt.firstSentAt = dateFromString(input, format: format)
            return self
        }
        
        func setCompleted(_ completed: Bool) -> Builder {
            self.sentPrompt.completed = completed
            self.sentPrompt.completedAt = Date()
            return self
        }
        
        func setPromptType(_ promptType: PromptType) -> Builder {
            self.sentPrompt.promptType = promptType
            return self
        }
        
        func build() -> SentPrompt {
            return self.sentPrompt
        }
        
    }
}

extension ReflectionPrompt {
    public class Builder {
        var prompt: ReflectionPrompt
        init(_ promptId: String) {
            self.prompt = ReflectionPrompt()
            self.prompt.id = promptId
            self.prompt.promptContentEntryId = promptId
        }
        
        func setQuestion(_ text: String?) -> Builder {
            self.prompt.question = text
            return self
        }
        
        func setPrompType(_ promptType: PromptType) -> Builder {
            self.prompt.promptType = promptType
            return self
        }
        
        func setPromptContentEntryId(_ entryId: String? ) -> Builder {
            self.prompt.promptContentEntryId = entryId
            return self
        }
        
        func build() -> ReflectionPrompt {
            return self.prompt
        }
    }
}

extension ReflectionResponse {
    public class Builder {
        var response: ReflectionResponse
        
        init(_ promptId: String?=nil) {
            self.response = ReflectionResponse()
            self.response.promptId = promptId
        }
        
        func setQuestion(_ question: String?) -> Builder {
            self.response.promptQuestion = question
            return self
        }
        
        func setText(_ text: String?) -> Builder {
            self.response.content.text = text
            return self
        }
        
        func setReflectionDate(_ date: Date) -> Builder {
            self.response.responseDate = date
            _ = self.response.addReflectionLog(date)
            return self
        }
        
        func setReflectionDate(_ string: String, format: String="yyyy-MM-dd") -> Builder {
            let date = dateFromString(string, format: format)
            self.response.responseDate = date
            if let d = date {
                _ = self.response.addReflectionLog(d)
            }
            
            return self
        }
        
        func build() -> ReflectionResponse {
            return self.response
        }
    }
}

extension Content {
    public class Builder {
        var content: Content
        
        init() {
            self.content = Content()
        }
        
        func setText(_ text: String) -> Builder {
            self.content.text = text
            return self
        }
        
        func setType(_ type: ContentType) -> Builder {
            self.content.contentType = type
            return self
        }
        
        func setBackgroundImage(blob index: Int) -> Builder {
            let url = MockData.getBlobImage(index)
            self.content.backgroundImage = ContentBackgroundImage(storageUrl: url)
            return self
        }
        
        func setBackgroundImage(url: String) -> Builder {
            self.content.backgroundImage = ContentBackgroundImage(storageUrl: url)
            return self
        }
        
        func setPhoto(blob index: Int) -> Builder {
            let url = MockData.getBlobImage(index)
            self.content.photo = ImageFile(storageUrl: url)
            return self
        }
        
        func setPhoto(url: String) -> Builder {
            self.content.photo = ImageFile(storageUrl: url)
            return self
        }
        
        func setQuote(quote: String, author: String, title: String) -> Builder {
            self.content.quote = Quote(text: quote, name: author, title: title)                        
            return self
        }
        
        func build() -> Content {
            return self.content
        }
    }
}

extension PromptContent {
    public class Builder {
        var promptContent: PromptContent
        
        init(_ id: String, promptId: String?=nil) {
            self.promptContent =  PromptContent()
            self.promptContent.entryId = id
            self.promptContent.promptId = promptId ?? id
        }
        
        @discardableResult
        func entryId(_ id: String) -> Builder {
            self.promptContent.entryId = id
            return self
        }
        
        @discardableResult
        func setPromptId(_ id: String) -> Builder {
            self.promptContent.promptId = id
            return self
        }        
        
        @discardableResult
        func custom(_ customize: (PromptContent) -> Void) -> Builder {
            customize(self.promptContent)
            return self
        }
        
        @discardableResult
        func setSubject(_ subject: String?) -> Builder {
            self.promptContent.subjectLine = subject
            return self
        }
        
        @discardableResult
        func addContent(_ text: String?, _ contentType: ContentType = .reflect, backgroundImage: String?=nil, photo: String?=nil) -> Builder {
            return self.add(MockData.content(text, contentType, backgroundImage: backgroundImage, photo: photo))
        }
        
        @discardableResult
        func addContent(_ text: String?, _ contentType: ContentType = .reflect, backgroundBlob: Int) -> Builder {
            let backgroundUrl = MockData.getBlobImage(backgroundBlob)
            return self.add(MockData.content(text, contentType, backgroundImage: backgroundUrl, photo: nil))
        }
        
        @discardableResult
        func addContent(_ text: String?, _ contentType: ContentType = .reflect, photoBlob: Int) -> Builder {
            let photoUrl = MockData.getBlobImage(photoBlob)
            return self.add(MockData.content(text, contentType, backgroundImage: nil, photo: photoUrl))
        }
        
        @discardableResult
        func add(_ content: Content) -> Builder {
            self.promptContent.content.append(content)
            return self
        }
        
        func build() -> PromptContent {
            return self.promptContent
        }
    }
}
