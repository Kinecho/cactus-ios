//
//  MockData.swift
//  Cactus
//
//  Created by Neil Poulin on 7/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

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
    
    static func EntryBuilder(question: String?, answer: String?, promptId: String="prompt1", memberId: String="m1") -> JournalEntry.Builder {
        let builder = JournalEntry.Builder(promptId)
            .setAllLoaded(true)
            .setPrompt(ReflectionPrompt.Builder(promptId)
                .setQuestion(question)
                .build())
            .setPromptContent(PromptContent.Builder(promptId)
                .addContent(answer, .text)
                .build())
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
    
    static func getLoadingEntry() -> JournalEntry {
        return MockData.EntryBuilder(question: "How come stuff loads for so long?", answer: nil)
            .setAllLoaded(false)
            .build()
        
    }
    
    static func getUnansweredEntry(isToday: Bool=false) -> JournalEntry {
        let builder = MockData.EntryBuilder(question: "How do you overcome **failure**?", answer: nil)
            .setAllLoaded(true)
            .prependContent(MockData.content("Today you'll focus on how you conquer difficult challenges and failure.", .text, backgroundImage: "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200707.png?alt=media&token=3ff817ca-f58f-457a-aff0-bbefebb095ad"))
            .setTodaysPrompt(isToday)
        
        return builder.build()
    }
    
    static func getAnsweredEntry(isToday: Bool=false) -> JournalEntry {
        let builder = MockData.EntryBuilder(question: "How do you overcome **failure**?", answer: nil)
            .setAllLoaded(true)
            .prependContent(MockData.content("Today you'll focus on how you conquer difficult challenges and failure.", .text, backgroundImage: "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200707.png?alt=media&token=3ff817ca-f58f-457a-aff0-bbefebb095ad"))
            .setTodaysPrompt(isToday)
            .addResponse(ReflectionResponse.Builder()
                .setText("I am going to reflect on the things that make me happy. Using Cactus will help me overcome a lot of bad things!")
                .build())
        
        return builder.build()
    }
    
}

extension JournalEntry {
    public class Builder {
        var entry: JournalEntry
        
        init(_ promptId: String?=nil) {
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

extension PromptContent {
    public class Builder {
        var promptContent: PromptContent
        
        init(_ id: String, promptId: String?=nil) {
            self.promptContent =  PromptContent()
            self.promptContent.entryId = id
            self.promptContent.promptId = promptId ?? id
        }
        
        func entryId(_ id: String) -> Builder {
            self.promptContent.entryId = id
            return self
        }
        
        func setPromptId(_ id: String) -> Builder {
            self.promptContent.promptId = id
            return self
        }        
        
        func custom(_ customize: (PromptContent) -> Void) -> Builder {
            customize(self.promptContent)
            return self
        }
        
        func setSubject(_ subject: String?) -> Builder {
            self.promptContent.subjectLine = subject
            return self
        }
        
        func addContent(_ text: String?, _ contentType: ContentType = .reflect, backgroundImage: String?=nil, photo: String?=nil) -> Builder {
            return self.add(MockData.content(text, contentType, backgroundImage: backgroundImage, photo: photo))
        }
        
        func add(_ content: Content) -> Builder {
            self.promptContent.content.append(content)
            return self
        }
        
        func build() -> PromptContent {
            return self.promptContent
        }
    }
}
