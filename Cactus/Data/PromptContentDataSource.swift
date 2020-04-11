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
    var pageLoaders: [PageLoader<PromptContent>] = []
    var promptContentDataByEntryId: [String: PromptContentData] = [:]
    var orderedData: [PromptContentData] = []
    var pageSize = 10
    
    init(element: CactusElement) {
        self.element = element
        self.start()
    }
    
    func handleMemberUpdated(oldMember: CactusMember?, newMember: CactusMember?) {
        self.logger.info("Member changed: \(newMember?.email ?? "unknown") | tier = \(newMember?.tier ?? .BASIC)")
    }
    
    func start() {
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            self.member = member
        })
        
        let firstPage = PageLoader<PromptContent>()
        self.pageLoaders.append(firstPage)
        
        firstPage.listener = PromptContentService.sharedInstance.observePromptContent(element: self.element, limit: self.pageSize) { (pageResult) in
            firstPage.result = pageResult
            self.logger.info("Got first page data with \(pageResult.results?.count ?? 0) results", functionName: "initializePages", line: #line)
//            firstPage.result = pageResult
            self.handlePageResult(pageResult)
            self.hasLoaded = true
        }
    }
    
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
        let promptContents = self.pageLoaders.compactMap {$0.result?.results}.flatMap {$0}
        self.orderedData = promptContents.compactMap { (promptContent) -> PromptContentData? in
            guard let entryId = promptContent.entryId else {
                return nil
            }
            if self.promptContentDataByEntryId[entryId] == nil {
                self.logger.debug("Setting up prompt content entry data source for promptId \(entryId)")
                self.promptContentDataByEntryId[entryId] = PromptContentData(promptContent, delegate: self)
            }
            
            let data = self.promptContentDataByEntryId[entryId]
            data?.promptContent = promptContent
            return data
        }
    }
}

extension PromptContentDataSource: PromptContentDataDelegate {
    func promptContentDataLoaded(promptContentData: PromptContentData) {
        self.logger.info("Prompt content data finished loading for entry: \(promptContentData.promptContent.entryId ?? "unknown"). Num responses = \(promptContentData.responseData.responses.count)")
    }
}
