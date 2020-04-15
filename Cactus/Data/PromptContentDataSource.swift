//
//  PromptContentDataSource.swift
//  Cactus
//
//  Created by Neil Poulin on 4/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol PromptContentDataSourceDelegate: class {
    func batchUpdate(addedIndexes: [Int], updatedIndexes: [Int], removedIndexes: [Int])
}

class PromptContentDataSource {
    
    // MARK: Static Members
    static var _logger = Logger("PromptContentDataSource")
    static var byElement: [CactusElement: PromptContentDataSource] = [:]
    static func forElement(_ element: CactusElement) -> PromptContentDataSource {
        if let existing = PromptContentDataSource.byElement[element] {
            return existing
        }
        
        _logger.info("Creating data source for element \(element.title)")
        let dataSource = PromptContentDataSource(element: element)
        self.byElement[element] = dataSource
        return dataSource
    }
    
    // MARK: Instance Members
    var pagesLoading: Bool {
        (self.pageLoaders.isEmpty ? !self.hasLoaded : self.pageLoaders.contains { !$0.allLoaded })
    }
    
    var isLoading: Bool {pagesLoading }
    
    var logger = Logger("PromptContentDataSource")
    var element: CactusElement
    var memberUnsubscriber: Unsubscriber?
    var member: CactusMember? {
        didSet {
            self.handleMemberUpdated(oldMember: oldValue, newMember: self.member)
        }
    }
    weak var delegate: PromptContentDataSourceDelegate?
    
    var count: Int {
        return self.orderedData.count
    }
    var hasLoaded = false
    var pageLoaders: [PromptContentPageLoader] = []
    var promptContentDataByEntryId: [String: PromptContentData] = [:]
    var orderedData: [PromptContentData] = []
    var pageSize = 10
    
    init(element: CactusElement) {
        self.element = element
        self.start()
    }
    
    func handleMemberUpdated(oldMember: CactusMember?, newMember: CactusMember?) {
        self.logger.info("Member changed: \(newMember?.email ?? "unknown") | tier = \(newMember?.tier ?? .BASIC)")
        if self.pageLoaders.isEmpty && newMember != nil && oldMember == nil {
            self.loadFirstPage()
        }
    }
    
    func start() {
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            self.member = member
        })
    }
    
    func loadFirstPage() {
        guard self.pageLoaders.isEmpty else {
            logger.info("First page already laoded")
            return
        }
        let firstPage = PromptContentPageLoader()
        firstPage.delegate = self
        self.pageLoaders.append(firstPage)
        
        firstPage.listener = PromptContentService.sharedInstance.observePromptContent(element: self.element, tier: self.member?.tier ?? .BASIC, limit: self.pageSize) { (pageResult) in
            firstPage.result = pageResult
            self.logger.info("Got first page data with \(pageResult.results?.count ?? 0) results", functionName: "initializePages", line: #line)
            //            firstPage.result = pageResult
//            self.handlePageResult(pageResult)
            firstPage.handlePageResult(pageResult)
//            self.hasLoaded = true
        }
    }
    
    //TODO: Move to page loader
    func handlePageResult(_ pageResult: PageResult<PromptContent>) {
        let removed = pageResult.removed?.compactMap({ (content) -> Int? in
            guard let id = content.entryId else {
                return nil
            }
            return self.index(entryId: id)
        }) ?? []
        
        self.updateOrderedData()
        let added = pageResult.added?.compactMap({ (content) -> Int? in
            guard let id = content.entryId else {
                return nil
            }
            return self.index(entryId: id)
        }) ?? []
        
        let updated = pageResult.updated?.compactMap({ (content) -> Int? in
            guard let id = content.entryId else {
                return nil
            }
            return self.index(entryId: id)
        }) ?? []
        
        self.delegate?.batchUpdate(addedIndexes: added, updatedIndexes: updated, removedIndexes: removed)
    }
    
    func get(index: Int) -> PromptContentData? {
        if self.orderedData.count > index {
            return self.orderedData[index]
        }        
        return nil
    }
    
    func get(entryId: String) -> PromptContentData? {
        return self.orderedData.first { (data) -> Bool in
            data.promptContent.entryId == entryId
        }
    }
    
    func index(entryId: String) -> Int? {
        return self.orderedData.firstIndex { (data) -> Bool in
            data.promptContent.entryId == entryId
        }
    }
    
    func updateOrderedData() {
        self.orderedData = self.pageLoaders.compactMap {$0.orderedPromptData}.flatMap {$0}
//        self.orderedData = promptContents.compactMap { (promptContent) -> PromptContentData? in
//            guard let entryId = promptContent.entryId else {
//                return nil
//            }
//            if self.promptContentDataByEntryId[entryId] == nil {
//                self.logger.debug("Setting up prompt content entry data source for promptId \(entryId)")
//                self.promptContentDataByEntryId[entryId] = PromptContentData(promptContent, delegate: self)
                
//            }
            
//            let data = self.promptContentDataByEntryId[entryId]
//            data?.promptContent = promptContent
//            data?.delegate = self
//            return data
//        }
//        return promptContentData
    }
    
    func loadNextPage() {
        self.logger.info("attempting to load next page", functionName: #function)
        
        guard !self.isLoading else {
            logger.info("Already loading more, can't fetch next page", functionName: #function)
            return
        }
        guard let member = self.member else {
            logger.warn("No current member found, can't load next page", functionName: #function)
            return
        }
        let nextIndex = self.pageLoaders.count
        let previousResult = self.pageLoaders.last?.result
        
        guard nextIndex == 0 || previousResult?.mightHaveMore == true else {
            logger.info("Previous page did not have more results, not attempting to fetch the next page")
            return
        }
        
        if previousResult == nil && nextIndex != 0 {
            logger.info("Page hasn't finished loading yet, can't fetch next page", functionName: #function, line: #line)
            return
        }
        
        self.logger.info("Creating page loader. This will be page \(nextIndex)", functionName: #function, line: #line)
        let page = PromptContentPageLoader()
        page.delegate = self
        self.pageLoaders.append(page)
        
        page.listener = PromptContentService.sharedInstance.observePromptContent(element: self.element, tier: member.tier, limit: self.pageSize, lastResult: previousResult) { (pageResult) in
            page.result = pageResult
            self.logger.info("Got first page data with \(pageResult.results?.count ?? 0) results", functionName: "initializePages", line: #line)
//            self.handlePageResult(pageResult)
            page.handlePageResult(pageResult)
        }
    }
}

extension PromptContentDataSource: PromptContentDataDelegate {
    func promptContentDataLoaded(promptContentData: PromptContentData) {
        self.logger.info("Prompt content data finished loading for entry: \(promptContentData.promptContent.entryId ?? "unknown"). Num responses = \(promptContentData.responseData.responses.count)")
        let foundIndex = self.orderedData.firstIndex { (data) -> Bool in
            return data == promptContentData
        }
        guard let index = foundIndex else {
            return
        }
        DispatchQueue.main.async {
            self.delegate?.batchUpdate(addedIndexes: [], updatedIndexes: [index], removedIndexes: [])
        }
    }
}

extension PromptContentDataSource: PromptContentPageLoaderDelegate {
    func pageUpdated(removed: [PromptContent]?, added: [PromptContent]?, updated: [PromptContent]?) {
        //no op
        self.logger.info("Page updated via delegate")
    }
    
    func pageLoader(pageLoader: PromptContentPageLoader, loadingFinished: Bool) {
        if loadingFinished {
            self.logger.info("Page loading finished")
            self.updateOrderedData()
            let added = pageLoader.orderedPromptContent?.compactMap({ (content) -> Int? in
                guard let entryId = content.entryId else {
                    return nil
                }
                return self.index(entryId: entryId)
            })
            self.delegate?.batchUpdate(addedIndexes: added ?? [], updatedIndexes: [], removedIndexes: [])
//            pageLoader.
            
        }
    }
}
