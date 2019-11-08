//
//  JournalFeedDataSource.swift
//  Cactus
//
//  Created by Neil Poulin on 9/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class PageLoader<T: FirestoreIdentifiable> {
    var result: PageResult<T>?
    var finishedLoading: Bool { result != nil }
    var pageIndex: Int
    var listener: ListenerRegistration?
    
    init(page index: Int) {
        self.pageIndex = index
    }
}

struct PromptData {
    var hasLoaded: Bool = false
    var unsubscriber: ListenerRegistration?
    var prompt: ReflectionPrompt?
}

struct ResponseData {
    var hasLoaded: Bool = false
    var unsubscriber: ListenerRegistration?
    var responses = [ReflectionResponse]()
}

struct ContentData {
    var hasLoaded: Bool = false
    var unsubscriber: ListenerRegistration?
    var promptContent: PromptContent?
}

protocol JournalEntryDataDelegate: class {
    func onData(_ journalEntry: JournalEntry)
}

class JournalEntryData {
    var promptId: String?
    var memberId: String
    var sentPrompt: SentPrompt
    var reflectionPromptData = PromptData()
    var responseData = ResponseData()
    var contentData = ContentData()
    private var wontLoad: Bool = false
    weak var delegate: JournalEntryDataDelegate?
    var loadingComplete: Bool {
        return self.wontLoad || self.reflectionPromptData.hasLoaded && self.responseData.hasLoaded && self.contentData.hasLoaded
    }
        
    func notifyIfLoadingComplete() {
        self.delegate?.onData(self.getJournalEntry())
    }
    
    init(sentPrompt: SentPrompt, memberId: String) {
        print("Setting up Journal Entry for promptId \(sentPrompt.promptId ?? "unknown")")
        self.sentPrompt = sentPrompt
        self.promptId = sentPrompt.promptId
        self.memberId = memberId
    }
    
    deinit {
        print("JournalEntryData deinit called for promptId \(sentPrompt.promptId ?? "unknown")")
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
        var entry = JournalEntry(self.sentPrompt)
        entry.prompt = self.reflectionPromptData.prompt
        entry.responses = self.responseData.responses
        entry.promptContent = self.contentData.promptContent
        entry.loadingComplete = self.loadingComplete
        
        entry.promptContentLoaded = self.contentData.hasLoaded
        entry.promptLoaded = self.reflectionPromptData.hasLoaded
        entry.responsesLoaded = self.responseData.hasLoaded
        
        return entry
    }
    
    func setupPromptObserver() {
        self.reflectionPromptData.unsubscriber?.remove()
        guard let promptId = self.promptId else {
            print("No prompt ID found on JournalEntryData, can't load data")
            self.wontLoad = true
            self.notifyIfLoadingComplete()
            return
        }
        
        self.reflectionPromptData.unsubscriber = ReflectionPromptService.sharedInstance.observeById(id: promptId, { (reflectionPrompt, error) in
            if let error = error {
                print("Error fetching reflection prompt. PromptID \(promptId)", error)
            }
            
            self.reflectionPromptData.prompt = reflectionPrompt
            self.reflectionPromptData.hasLoaded = true
            self.notifyIfLoadingComplete()
        })
        
        self.responseData.unsubscriber = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
            if let error = error {
                print("Failed to load reflection responses. PromptID \(promptId)", error)
            }
            if let responses = responses {
                self.responseData.responses = responses
            }
            self.responseData.hasLoaded = true
            self.notifyIfLoadingComplete()
        })
        
        self.contentData.unsubscriber = PromptContentService.sharedInstance.observeForPromptId(promptId: promptId) { (promptContent, error) in
            if let error = error {
                print("Failed to load promptContent. PromptID \(promptId)", error)
            }
            if let promptContent = promptContent {
                self.contentData.promptContent = promptContent
            }
            self.contentData.hasLoaded = true
            self.notifyIfLoadingComplete()
        }
    }
}

struct JournalEntry: Equatable {
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.prompt?.id == rhs.prompt?.id
            && lhs.sentPrompt.id == rhs.sentPrompt.id
            && lhs.responses?.count == rhs.responses?.count
            && lhs.promptContent?.entryId == rhs.promptContent?.entryId
            && lhs.loadingComplete == rhs.loadingComplete
    }
    
    var prompt: ReflectionPrompt?
    var promptLoaded: Bool = false
    var sentPrompt: SentPrompt
    var responses: [ReflectionResponse]?
    var responsesLoaded: Bool = false
    var promptContent: PromptContent?
    var promptContentLoaded: Bool = false
    
    var loadingComplete: Bool = false
    
    init(_ sentPrompt: SentPrompt) {
        self.sentPrompt = sentPrompt
    }
}

protocol JournalFeedDataSourceDelegate: class {
    func updateEntry(_ journalEntry: JournalEntry, at: Int?)
    func insert(_ journalEntry: JournalEntry, at: Int?)
//    func remove(_ journalEntry: JournalEntry, at: Int)
    func removeItems(_ indexes: [Int])
    func insertItems(_ indexes: [Int])
    func dataLoaded()
    func loadingCompleted()
}

class JournalFeedDataSource {
    var currentMember: CactusMember?
    var journalEntryDataBySentPromptId: [String: JournalEntryData] = [:]
    var sentPrompts: [SentPrompt] = []
    var count: Int {
        return self.orderedPromptIds.count
    }
    var orderedPromptIds: [String] = []
    
    var promptsListener: ListenerRegistration?
    var memberUnsubscriber: (() -> Void)?
    
    weak var delegate: JournalFeedDataSourceDelegate?
    
    func resetData() {
        self.orderedPromptIds.removeAll()
        self.unsubscribeAll()
        journalEntryDataBySentPromptId.removeAll()
        self.delegate?.dataLoaded()
    }
    
    func unsubscribeAll() {
        memberUnsubscriber?()
        promptsListener?.remove()
    }
    
    var currentStreak: Int {
        return calculateStreak(self.responses)
    }
    
    var responses: [ReflectionResponse] {
        return journalEntryDataBySentPromptId.values.flatMap { (entry) -> [ReflectionResponse] in
            return entry.responseData.responses
        }
    }
    
    var totalReflections: Int {
        return responses.count
    }
    
    var totalReflectionDurationMs: Int {
        return self.responses.reduce(0) { (totalMs, response) -> Int in
            return totalMs + (response.reflectionDurationMs ?? 0)
        }
    }
    
    var loadingCompleted: Bool {
        return !journalEntryDataBySentPromptId.values.contains(where: { (entry) -> Bool in
            return !entry.loadingComplete
        })
    }
    
    var pageListeners: [ListenerRegistration] = []
    var pages: [PageLoader<SentPrompt>] = []
    var pageSize: Int = 10
    var mightHaveMore: Bool {self.pages.last?.result?.mightHaveMore ?? false}
    
    var isLoading: Bool {self.pages.contains { !$0.finishedLoading } }
    
    deinit {
        print("Deinit JournalFeedDataSource. Unsubscribing from all data")
        self.unsubscribeAll()
    }
    
    init() {
        print("Creating JournalFeedDataSource")
        self.start()
    }
    
    func start() {
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            if self.currentMember != member {
                self.resetData()
            }
            self.currentMember = member
            self.loadNextPage()
        })
    }
    
    func loadNextPage() {
        print("[JournalFeedDataSource] attempting to load  next page")
        
        guard !self.isLoading else {
            print("Already loading more, can't fetch next page")
            return
        }
        guard let member = self.currentMember else {
            print("[JouranlFeedDataSource] No current member found, can't load next page")
            return
        }
        let nextIndex = self.pages.count
        let previousResult = self.pages.last?.result
        
        if previousResult == nil && nextIndex != 0 {
            print("Page hasn't finished loading yet, can't fetch next page")
            return
        }
        
        let page = PageLoader<SentPrompt>(page: nextIndex)
        self.pages.append(page)
        page.listener = SentPromptService.sharedInstance.observeSentPromptsPage(member: member, limit: self.pageSize, lastResult: previousResult, { (pageResult) in
            page.result = pageResult
            let removedPromptIds: [String]? = page.result?.removed?.compactMap({ (sentPrompt) -> String? in
                return sentPrompt.promptId
            })
            
            let removedIndexes: [Int] = removedPromptIds?.compactMap { promptId in
                return self.orderedPromptIds.firstIndex(of: promptId)
            } ?? []
                                    
            self.configurePages()
            
            if !removedIndexes.isEmpty {
                self.delegate?.removeItems(removedIndexes)
            }
        })
    }
    
    func configurePages() {
        let prompts: [SentPrompt] = self.pages.compactMap {$0.result?.results}.flatMap {$0}
        self.sentPrompts = prompts
        //Below is copied from initPrompts
        
        self.initSentPrompts()
    }
    
    func checkForNewPrompts() {
        print("checkForNewPrompts called")
        guard let member = self.currentMember else {
            return
        }
        let first = self.pages.first?.result?.firstSnapshot
        SentPromptService.sharedInstance.getSentPrompts(member: member, limit: 10, before: first) { (sentPrompts, error) in
            if let error = error {
                print("Error checking for new prompts", error)
            }
            
            guard let sentPrompts = sentPrompts else {
                return
            }
                        
            sentPrompts.reversed().forEach { (sentPrompt) in
                if !self.sentPrompts.contains(sentPrompt) {
                    print("found a new prompt!")
                    self.sentPrompts.insert(sentPrompt, at: 0)
                }
            }
            self.initSentPrompts()
        }
    }
    
    func get(at index: Int) -> JournalEntry? {
        guard index < self.orderedPromptIds.count && index >= 0 else {
            return nil
        }
        let promptId = self.orderedPromptIds[index]
        guard let data = self.journalEntryDataBySentPromptId[promptId] else {
            return nil
        }
        
        return data.getJournalEntry()
    }
    
    func indexOf(_ journalEntry: JournalEntry) -> Int? {
        guard let promptId = journalEntry.sentPrompt.promptId else {
            return nil
        }
        
        return self.orderedPromptIds.firstIndex(of: promptId)
    }
    
    func initSentPrompts() {
        guard let memberId = self.currentMember?.id else {
            return
        }

        var createdEntries: [JournalEntryData] = []
        var insertedIndexes: [Int] = []
        var orderedPromptIds = [String]()
        for (index, sentPrompt) in self.sentPrompts.enumerated() {
            guard let promptId = sentPrompt.promptId, !orderedPromptIds.contains(promptId) else {
                return
            }
            if self.journalEntryDataBySentPromptId[promptId] == nil {
                print("Setting up journal entry data source for promptId \(promptId)")
                let journalEntry = JournalEntryData(sentPrompt: sentPrompt, memberId: memberId)
                journalEntry.delegate = self
                createdEntries.append(journalEntry)
                self.journalEntryDataBySentPromptId[promptId] = journalEntry
                insertedIndexes.append(index)
            }
            orderedPromptIds.append(promptId)
        }
        self.orderedPromptIds = orderedPromptIds
        
        if self.pages.count == 1 {
            self.delegate?.dataLoaded()
        } else if !insertedIndexes.isEmpty {
            self.delegate?.insertItems(insertedIndexes)
        }
        createdEntries.forEach {$0.start()}
//        self.delegate?.dataLoaded()
    }
}

extension JournalFeedDataSource: JournalEntryDataDelegate {
    //TODO: Deal with deleted entries/sent prompts
    func onData(_ journalEntry: JournalEntry) {
        let index = self.indexOf(journalEntry)
        self.delegate?.updateEntry(journalEntry, at: index)
        
        if self.loadingCompleted {
            self.delegate?.loadingCompleted()
        }
    }

    //TODO: add update, deleted, add handlers
}
