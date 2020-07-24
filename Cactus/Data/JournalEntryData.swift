//
//  JournalEntryData.swift
//  Cactus
//
//  Created by Neil Poulin on 11/8/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct PromptData {
    var hasLoaded: Bool = false
    var unsubscriber: DataObserver?
    var prompt: ReflectionPrompt?
}

struct ResponseData {
    var hasLoaded: Bool = false
    var unsubscriber: DataObserver?
    var responses = [ReflectionResponse]()
}

struct ContentData {
    var hasLoaded: Bool = false
    var unsubscriber: DataObserver?
    var promptContent: PromptContent?
}

protocol JournalEntryDataDelegate: class {
    func onData(_ journalEntry: JournalEntry)
}

class JournalEntryData {
    static var logger = Logger(fileName: "JournalEntryData")
    var promptId: String?
    var memberId: String
    var sentPrompt: SentPrompt?
    var reflectionPromptData = PromptData()
    var responseData = ResponseData()
    var contentData = ContentData()
    var journalDate: Date?
    var isTodaysPrompt: Bool = false
    
    private var wontLoad: Bool = false
    weak var delegate: JournalEntryDataDelegate?
    var loadingComplete: Bool {
        return self.wontLoad || self.reflectionPromptData.hasLoaded && self.responseData.hasLoaded && self.contentData.hasLoaded
    }
        
    func notifyIfLoadingComplete() {
        self.delegate?.onData(self.getJournalEntry())
    }
    
    init(sentPrompt: SentPrompt, memberId: String) {
        JournalEntryData.logger.debug("Setting up Journal Entry for promptId \(sentPrompt.promptId ?? "unknown")", functionName: #function, line: #line)
        self.sentPrompt = sentPrompt
        self.promptId = sentPrompt.promptId
        self.memberId = memberId
        self.journalDate = sentPrompt.firstSentAt
    }
    
    init(promptId: String?, memberId: String, journalDate: Date?) {
        JournalEntryData.logger.debug("Setting up Journal Entry without a SentPrompt for promptId \(promptId ?? "unknown")", functionName: #function, line: #line)
        self.promptId = promptId
        self.memberId = memberId
        self.journalDate = journalDate
    }
    
    deinit {
        JournalEntryData.logger.info("JournalEntryData deinit called for promptId \(self.promptId ?? "unknown")")
        self.stop()
    }
    
    func stop() {
        JournalEntryData.logger.info("Stopping the journal entry observers")
        self.reflectionPromptData.unsubscriber?.remove()
        self.responseData.unsubscriber?.remove()
        self.contentData.unsubscriber?.remove()
    }
    
    func start() {
        guard self.reflectionPromptData.unsubscriber == nil else {
            return
        }
        self.setupPromptObserver()
    }
    
    func getJournalEntry() -> JournalEntry {
        var entry = JournalEntry(promptId: self.promptId)
        entry.sentPrompt = self.sentPrompt
        entry.prompt = self.reflectionPromptData.prompt
        entry.responses = self.responseData.responses
        entry.promptContent = self.contentData.promptContent
        entry.loadingComplete = self.loadingComplete
        
        entry.promptContentLoaded = self.contentData.hasLoaded
        entry.promptLoaded = self.reflectionPromptData.hasLoaded
        entry.responsesLoaded = self.responseData.hasLoaded
        entry.journalDate = self.journalDate
        entry.isTodaysPrompt = self.isTodaysPrompt
        return entry
    }
    
    func setupPromptObserver() {
        self.reflectionPromptData.unsubscriber?.remove()
        guard let promptId = self.promptId, !isBlank(promptId) else {
            JournalEntryData.logger.info("No prompt ID found on JournalEntryData, can't load data")
            self.wontLoad = true
            self.notifyIfLoadingComplete()
            return
        }
        
        self.reflectionPromptData.unsubscriber = ReflectionPromptService.sharedInstance.observeById(id: promptId, { (reflectionPrompt, error) in
            if let error = error {
                JournalEntryData.logger.error("Error fetching reflection prompt. PromptID \(promptId)", error, functionName: #function, line: #line)
            }
            
            self.reflectionPromptData.prompt = reflectionPrompt
            self.reflectionPromptData.hasLoaded = true
            self.notifyIfLoadingComplete()
        })
        
        self.responseData.unsubscriber = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
            if let error = error {
                JournalEntryData.logger.error("Failed to load reflection responses. PromptID \(promptId)", error, functionName: #function, line: #line)
            }
            if let responses = responses {
                self.responseData.responses = responses
            }
            self.responseData.hasLoaded = true
            self.notifyIfLoadingComplete()
        })
        
        self.contentData.unsubscriber = PromptContentService.sharedInstance.observeForPromptId(promptId: promptId) { (promptContent, error) in
            if let error = error {
                JournalEntryData.logger.error("Failed to load promptContent. PromptID \(promptId)", error, functionName: #function, line: #line)
            }
            if let promptContent = promptContent {
                self.contentData.promptContent = promptContent
            }
            self.contentData.hasLoaded = true
            self.notifyIfLoadingComplete()
        }
    }
}

struct JournalEntry: Equatable, Identifiable {
    var id: String {
        return self.promptId ?? "not-set"
    }

    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.prompt?.id == rhs.prompt?.id
            && lhs.sentPrompt?.id == rhs.sentPrompt?.id
            && lhs.promptId == rhs.promptId
            && lhs.responses?.count == rhs.responses?.count
            && lhs.promptContent?.entryId == rhs.promptContent?.entryId
            && lhs.loadingComplete == rhs.loadingComplete
    }
    
    var prompt: ReflectionPrompt?
    var promptLoaded: Bool = false
    var sentPrompt: SentPrompt?
    var responses: [ReflectionResponse]?
    var responsesLoaded: Bool = false
    var promptContent: PromptContent?
    var promptContentLoaded: Bool = false
    var promptId: String?
    var loadingComplete: Bool = false
    var journalDate: Date?
    var isTodaysPrompt: Bool = false
    
    init(promptId: String?) {
        self.promptId = promptId
        
    }

    
   var questionText: String? {
       return self.promptContent?.getDisplayableQuestion() ?? self.prompt?.question
   }
   
    var introText: String? {
        return self.promptContent?.getIntroTextMarkdown()
    }
    
   var imageUrl: URL? {
       let photo = self.promptContent?.getMainImageFile()
       return ImageService.shared.getUrlFromFile(photo)
   }
   
   var dateString: String? {
       if self.isTodaysPrompt {
           return "Today"
       }
       
       guard let date = self.sentPrompt?.firstSentAt ?? self.responses?.first?.createdAt else {
           return nil
       }
               
       return FormatUtils.formatDate(date)
   }
    
//    var isTodaysPrompt: Bool {
//        guard let date = self.journalDate, self.sentPrompt == nil else {
//            return false
//        }
//
//        let journalString = getFlamelinkDateStringAtMidnight(for: date)
//        let currentString = getFlamelinkDateStringAtMidnight(for: Date())
//        return journalString == currentString
//    }
    
}
