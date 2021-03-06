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

class PageLoader<T> {
    var result: PageResult<T>?
    var finishedLoading: Bool { result != nil }
    var listener: ListenerRegistration?
    
    init() {}
}

protocol JournalFeedDataSourceDelegate: class {
    func updateEntry(_ journalEntry: JournalEntry, at: Int?)
    func insert(_ journalEntry: JournalEntry, at: Int?)
    func removeItems(_ indexes: [Int])
    func insertItems(_ indexes: [Int])
    func batchUpdate(addedIndexes: [Int], removedIndexes: [Int])
    func dataLoaded()
    func handleEmptyState(hasResults: Bool)
    func setTodayEntry(_ journalEntry: JournalEntry?)
    func setOnboardingEntry(_ journalEntry: JournalEntry?)
}

class JournalFeedDataSource {
    var logger = Logger("JournalFeedDataSource")
    var currentMember: CactusMember? {
        didSet {
            handleMemberUpdated(oldMember: oldValue, newMember: self.currentMember)
        }
    }
    var appSettings: AppSettings? {
        didSet {
            handleSettingsChanged(current: self.appSettings, previous: oldValue)
        }
    }
    
    var journalEntryDataByPromptId: [String: JournalEntryData] = [:]
    var sentPrompts: [SentPrompt] = []
    var count: Int {
        return self.orderedPromptIds.count
    }
    var orderedPromptIds: [String] = []
    
    weak var delegate: JournalFeedDataSourceDelegate?
    
    // swiftlint:disable:next weak_delegate
    var todayDelegate: TodayEntryDelegate?
    // swiftlint:disable:next weak_delegate
    var onboardingDelegate: OnboardingEntryDelegate?
    
    var hasLoaded = false
    func resetData() {
        self.unsubscribeAll()
        self.orderedPromptIds.removeAll()
        self.pages.removeAll()
        self.todayData = nil        
        journalEntryDataByPromptId.removeAll()
        self.hasStarted = false
        self.hasLoaded = false
        
        self.delegate?.dataLoaded()
    }
    
    func unsubscribeAll() {
        self.pages.forEach { (page) in
            page.listener?.remove()
        }
        journalEntryDataByPromptId.values.forEach { (entry) in
            entry.stop()
        }
    }
    
    var currentStreak: Int {
        return calculateStreak(self.responses)
    }
    
    var responses: [ReflectionResponse] {
        return journalEntryDataByPromptId.values.flatMap { (entry) -> [ReflectionResponse] in
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
        return !journalEntryDataByPromptId.values.contains(where: { (entry) -> Bool in
            return !entry.loadingComplete
        }) && todayData?.loadingComplete == true
    }
    
    var pageListeners: [ListenerRegistration] = []
    var pages: [PageLoader<SentPrompt>] = []
    var pageSize: Int = 15
    var mightHaveMore: Bool {self.pages.last?.result?.mightHaveMore ?? false}
    
    var todayDateString: String?
    var todayData: JournalEntryData?
    var todayLoaded: Bool = false
    
    var isTodayLoading: Bool {
        !todayLoaded || todayData?.loadingComplete != true
    }
    var pagesLoading: Bool {
        (self.pages.isEmpty ? !self.hasLoaded : self.pages.contains { !$0.finishedLoading })
    }
    
    var isLoading: Bool {isTodayLoading || pagesLoading }
    
    deinit {
        logger.info("Deinit JournalFeedDataSource. Unsubscribing from all data")
        self.unsubscribeAll()
        self.delegate = nil
        self.resetData()
    }
    
    init(member: CactusMember?=nil, appSettings: AppSettings?=nil) {
        self.currentMember = member
        self.appSettings = appSettings
        self.todayDelegate = TodayEntryDelegate(self)
        self.onboardingDelegate = OnboardingEntryDelegate(self)
    }
    
    var startDate: Date?
    var hasStarted: Bool = false
    func start() {
        if hasStarted {
            self.logger.warn("data source has already been started. Returning")
            return
        }
        
        if self.currentMember == nil {
            self.logger.info("No member found, returning", functionName: #function)
            return
        }
        self.logger.info("Starting journal feed data source")
        self.hasStarted = true
        self.initializePages()
        self.initializeToday()
        self.fetchOnboardingPrompt()
        NotificationCenter.default.addObserver(self, selector: #selector(self.dayChanged), name: .NSCalendarDayChanged, object: nil)
        
    }
    
    var onlyCompletedPrompts: Bool {
        let tier = self.currentMember?.tier ?? .BASIC
        let enabledTiers: [SubscriptionTier] = self.appSettings?.journal?.enableAllSentPromptsForTiers ?? []
        let onlyCompleted = !enabledTiers.contains(tier)
        logger.info("Using only completed = \(onlyCompleted)")
        return onlyCompleted
    }
    
    func handleSettingsChanged(current: AppSettings?, previous: AppSettings?) {
        let currentTiers: [SubscriptionTier] = current?.journal?.enableAllSentPromptsForTiers ?? []
        let previousTiers: [SubscriptionTier] = previous?.journal?.enableAllSentPromptsForTiers ?? []
        guard !currentTiers.containsSameElements(as: previousTiers) else {
            logger.info("Enabled Tiers are the same, not doing anything")
            return
        }
        
        logger.info("Settings have changed")
        self.resetData()
        self.start()
    }
    
    func handleMemberUpdated(oldMember: CactusMember?, newMember: CactusMember?) {
        if newMember == nil || oldMember?.tier == newMember?.tier {
            return
        }
        logger.info("Member has changed subscription status, updating today query")
        self.resetData()
        self.start()
    }
    
    @objc func dayChanged() {
        self.logger.debug("Day changed called")
        self.initializeToday()
    }
    
    func initializeToday() {
        guard let memberId = self.currentMember?.id else {
            self.logger.warn("[JouranlFeedDataSource] No current member found, can't initialize today entry")
            self.todayLoaded = true
            return
        }
        
        let currentDate = Date()
        let currentDateString = getFlamelinkDateStringAtMidnight(for: currentDate)
        self.logger.debug("currentDateString=\(currentDateString ?? "unknown") | storedDateString=\(self.todayDateString ?? "unknown")")
        ///ensure the dates are different, otherwise do nothing
        guard self.todayDateString != currentDateString else {
            self.todayLoaded = true
            self.logger.debug("The stored date and the current dates strings are equal, so we will not process the today prompt")
            return
        }
        
        PromptContentService.sharedInstance.getPromptContent(for: currentDate, status: .published, member: self.currentMember) { (promptContent, error) in
            defer {
                self.todayLoaded = true
            }
            if let error = error {
                self.logger.error("Failed to fetch todays prompt content", error)
                self.delegate?.setTodayEntry(nil)
                return
            }
            
            guard let promptId = promptContent?.promptId else {
                self.logger.warn("There was no error loading todays prompt content, but no promptId was found.")
                self.delegate?.setTodayEntry(nil)
                return
            }
            //TODO: do we want to remove the todayData object if no new prompt is found?
            if let oldData = self.todayData {
                oldData.isTodaysPrompt = false
                oldData.delegate?.onData(oldData.getJournalEntry())
                oldData.stop()
                self.logger.info("Had old data for Today Prompt, used to remove it but am not anymore")
            }
            
            self.todayDateString = currentDateString
            
            let todayEntry = JournalEntryData(promptId: promptId, memberId: memberId, journalDate: currentDate)
            todayEntry.isTodaysPrompt = true
            self.todayData = todayEntry
            self.journalEntryDataByPromptId[promptId] = todayEntry
            todayEntry.delegate = self.todayDelegate
            self.configureDataFeed()
            todayEntry.start()
            self.todayLoaded = true
        }
    }
    
    func initializePages() {
        guard let member = self.currentMember else {
            self.logger.warn("[JouranlFeedDataSource] No current member found, can't start pages")
            return
        }
        
        let futurePage = PageLoader<SentPrompt>()
        self.pages.insert(futurePage, at: 0)
        
        let startDate = Date()
        self.startDate = startDate
        futurePage.listener = SentPromptService.sharedInstance.observeFuturePrompts(member: member, since: startDate, onlyCompleted: self.onlyCompletedPrompts, limit: nil, { (pageResult) in
            futurePage.result = pageResult
            self.logger.info("Got \"future\" journal entry data with \(pageResult.results?.count ?? 0) results", functionName: "initializePages", line: #line)
            
            if !(pageResult.results?.isEmpty ?? true) && self.hasLoaded {
                // need to update the UI for the first appearance so we can show onboarding
//                self.delegate?.handleEmptyState(hasResults: true)
            }
            
            self.configurePages()
        })
        
        let firstPage = PageLoader<SentPrompt>()
        self.pages.insert(firstPage, at: 1)
        firstPage.listener = SentPromptService.sharedInstance.observeSentPromptsPage(
            member: member,
            beforeOrEqualTo: startDate,
            onlyCompleted: self.onlyCompletedPrompts,
            limit: self.pageSize,
            lastResult: nil, { (pageResult) in
                firstPage.result = pageResult
                self.logger.info("Got first page data with \(pageResult.results?.count ?? 0) results",
                    functionName: "initializePages", line: #line)
                
                if !self.hasLoaded {
                    self.delegate?.handleEmptyState(hasResults: (pageResult.results?.isEmpty == false))
                }
                
                self.configurePages()
                self.hasLoaded = true
                self.delegate?.dataLoaded()
        })
    }
    
    func loadNextPage() {
        self.logger.info("attempting to load next page", functionName: #function)
        
//        guard !self.pagesLoading else {
//            logger.info("Already loading more, can't fetch next page", functionName: #function)
//            return
//        }
        guard let member = self.currentMember else {
            logger.warn("No current member found, can't load next page", functionName: #function)
            return
        }
        let nextIndex = self.pages.count
        let previousResult = self.pages.last?.result
        
        guard nextIndex == 0 || previousResult?.mightHaveMore == true else {
            logger.info("Previous page did not have more results, not attempting to fetch the next page")
            return
        }
        
        if previousResult == nil && nextIndex != 0 {
            logger.info("Page hasn't finished loading yet, can't fetch next page", functionName: #function, line: #line)
            return
        }
        
        self.logger.info("Creating page loader. This will be page \(nextIndex)", functionName: #function, line: #line)
        let page = PageLoader<SentPrompt>()
        self.pages.append(page)
        page.listener = SentPromptService.sharedInstance.observeSentPromptsPage(member: member,
                                                                                onlyCompleted: self.onlyCompletedPrompts,
                                                                                limit: self.pageSize,
                                                                                lastResult: previousResult, { (pageResult) in
            page.result = pageResult
            self.logger.info("Got page data with \(pageResult.results?.count ?? 0) results", functionName: "JournalFeedDataSource", line: #line)
            self.configurePages()
        })
    }
    
    func configurePages() {
        self.logger.info("configuring page data", functionName: #function, line: #line)
        let prompts: [SentPrompt] = self.pages.compactMap {$0.result?.results}.flatMap {$0}
        self.sentPrompts = prompts
        
        self.configureDataFeed()
    }
    
    func checkForNewPrompts(_ completed: (([SentPrompt]?) -> Void)? = nil) {
        logger.info("checkForNewPrompts called")
        guard let member = self.currentMember else {
            return
        }
        let first = self.pages.first?.result?.firstSnapshot
        SentPromptService.sharedInstance.getSentPrompts(member: member, limit: 10, before: first) { (sentPrompts, error) in
            if let error = error {
                self.logger.error("Error checking for new prompts", error)
            }
            
            guard let sentPrompts = sentPrompts else {
                self.logger.info("NO sent prompts found")
                return
            }
            
            sentPrompts.reversed().forEach { (sentPrompt) in
                if !self.sentPrompts.contains(sentPrompt) {
                    self.logger.custom("found a new prompt!", icon: Emoji.tada)
                    self.sentPrompts.insert(sentPrompt, at: 0)
                }
            }
            self.configureDataFeed()
        }
    }
    
    func fetchOnboardingPrompt() {
        
        guard let entryId = self.appSettings?.firstPromptContentEntryId, let memberId = self.currentMember?.id else {
            return
        }
        if self.journalEntryDataByPromptId[entryId] != nil {
            return
        }
        let data = JournalEntryData(entryId: entryId, memberId: memberId, journalDate: nil)
        data.delegate = self.onboardingDelegate
        data.start()
    }
    
    func get(at index: Int) -> JournalEntry? {
        guard index < self.orderedPromptIds.count && index >= 0 else {
            return nil
        }
        let promptId = self.orderedPromptIds[index]
        guard let data = self.journalEntryDataByPromptId[promptId] else {
            return nil
        }
        
        return data.getJournalEntry()
    }
    
    func indexOf(_ journalEntry: JournalEntry) -> Int? {
        guard let promptId = journalEntry.promptId else {
            return nil
        }
        
        return self.orderedPromptIds.firstIndex(of: promptId)
    }
    
    func configureDataFeed() {
        guard let memberId = self.currentMember?.id else {
            self.logger.warn("No member or memberId was found on the data feed", functionName: #function, line: #line)
            return
        }
        ///make a copy of sent prompts so that it doesn't get changed out from underneath us while iterating.
        let sentPrompts = self.sentPrompts
        var createdEntries: [JournalEntryData] = []
        var newPromptIds: [String] = []
        var updatedOrderedPromptIds = [String]()
        
        var promptIds = sentPrompts.map { (sentPrompt) -> String in
            return sentPrompt.promptId ?? "unknkown"
        }
        
        let todayPromptId = self.todayData?.promptId
        
        if todayPromptId != nil {
            self.logger.debug("Inserting today's promptId (\(todayPromptId!)) to the promptId array at position 0")
            promptIds.insert(todayPromptId!, at: 0)
        }
        
        self.logger.info("configurePages, sentPrompt.promptIds \(promptIds.joined(separator: "\n"))")
        var sentPromptIndex = 0
        sentPrompts.forEach { sentPrompt in
            defer {
                sentPromptIndex += 1
            }
            guard let promptId = sentPrompt.promptId else {
                self.logger.warn("No prompt ID found for SentPrompt.id = \(sentPrompt.id ?? "unknown")")
                return
            }
            guard !updatedOrderedPromptIds.contains(promptId) else {
                let existingIndex = updatedOrderedPromptIds.firstIndex(of: promptId)
                //                self.logger.info("sentPrompts.forEach, orderedPromptIds: \(updatedOrderedPromptIds.joined(separator: "\n"))")
                self.logger.warn("\(Emoji.redFlag) (Not fixed) Index=\(sentPromptIndex). ordered prompt ids already contains promptId \(promptId) at index \(existingIndex ?? -1). " +
                    "SentPromptId = \(sentPrompt.id ?? "unknown") This shouldn't happen, but will not affect user experience. PromptID = \(sentPrompt.promptId ?? "unknown")")
                return
            }
            if self.journalEntryDataByPromptId[promptId] == nil {
                self.logger.debug("Setting up journal entry data source for promptId \(promptId)")
                let journalEntry = JournalEntryData(sentPrompt: sentPrompt, memberId: memberId)
                journalEntry.delegate = self
                createdEntries.append(journalEntry)
                self.journalEntryDataByPromptId[promptId] = journalEntry
                newPromptIds.append(promptId)
            }
            updatedOrderedPromptIds.append(promptId)
        }
        
        if let todayPromptId = self.todayData?.promptId {
            ///remove all existing entries that have the same prompt ID as today's prompt
            updatedOrderedPromptIds.removeAll { (id) -> Bool in
                id == todayPromptId
            }
            updatedOrderedPromptIds.insert(todayPromptId, at: 0)
        }
        
        self.logger.info("Adding new prompts: \(newPromptIds)")
        var insertedIndexes: [Int] = []
        for (index, id) in updatedOrderedPromptIds.enumerated() {
            if !self.orderedPromptIds.contains(id) {
                insertedIndexes.append(index)
            }
        }
        
        //get removed indexes
        var removedIndexes: [Int] = []
        for (index, id) in self.orderedPromptIds.enumerated() {
            if !updatedOrderedPromptIds.contains(id) {
                removedIndexes.append(index)
            }
        }
        self.logger.info("found \(removedIndexes.count) removed indexes")
        
        self.orderedPromptIds = updatedOrderedPromptIds
        
        if !removedIndexes.isEmpty && !insertedIndexes.isEmpty {
            self.logger.info("Performing batch update")
            self.delegate?.batchUpdate(addedIndexes: insertedIndexes, removedIndexes: removedIndexes)
        } else if !removedIndexes.isEmpty {
            self.delegate?.removeItems(removedIndexes)
        } else if !insertedIndexes.isEmpty {
            self.delegate?.insertItems(insertedIndexes)
        }
        
        createdEntries.forEach {$0.start()}
    }
}

extension JournalFeedDataSource: JournalEntryDataDelegate {
    func onData(_ journalEntry: JournalEntry) {
        if journalEntry.loadingComplete {
            guard let index = self.indexOf(journalEntry) else {
                self.logger.warn("No index foud for journalEntry.promptId \(journalEntry.promptId ?? "unknown")")
                return
            }
            
            self.delegate?.updateEntry(journalEntry, at: index)
        }
    }
}

extension JournalFeedDataSource {
    class TodayEntryDelegate: JournalEntryDataDelegate {
        var parent: JournalFeedDataSource
        
        init(_ parent: JournalFeedDataSource) {
            self.parent = parent
        }
        
        func onData(_ journalEntry: JournalEntry) {
            self.parent.delegate?.setTodayEntry(journalEntry)
            if journalEntry.loadingComplete {
                guard let index = self.parent.indexOf(journalEntry) else {
                    self.parent.logger.warn("No index foud for journalEntry.promptId \(journalEntry.promptId ?? "unknown")")
                    return
                }
                
                self.parent.delegate?.updateEntry(journalEntry, at: index)
            }
        }
    }
    
    class OnboardingEntryDelegate: JournalEntryDataDelegate {
        var parent: JournalFeedDataSource
        
        init(_ parent: JournalFeedDataSource) {
            self.parent = parent
        }
        
        func onData(_ journalEntry: JournalEntry) {
            self.parent.delegate?.setOnboardingEntry(journalEntry)
            if journalEntry.loadingComplete {
                guard let index = self.parent.indexOf(journalEntry) else {
                    self.parent.logger.warn("No index foud for journalEntry.promptId \(journalEntry.promptId ?? "unknown")")
                    return
                }
                
                self.parent.delegate?.updateEntry(journalEntry, at: index)
            }
        }
    }
}
