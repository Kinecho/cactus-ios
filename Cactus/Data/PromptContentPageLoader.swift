//
//  PromptContentPageLoader.swift
//  Cactus
//
//  Created by Neil Poulin on 4/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation


protocol PromptContentPageLoaderDelegate: class {
    func pageLoader(pageLoader: PromptContentPageLoader, loadingFinished: Bool)
    func pageUpdated(removed: [PromptContent]?, added: [PromptContent]?, updated: [PromptContent]?)
}

class PromptContentPageLoader: PageLoader<PromptContent>, PromptContentDataDelegate {
    let logger = Logger("PromptContentPageLoader")
    var delegate: PromptContentPageLoaderDelegate?
    
    var promptContentDataByEntryId: [String: PromptContentData] = [:]
    var orderedPromptData: [PromptContentData]?
    
    var orderedPromptContent: [PromptContent]? {
        self.orderedPromptData?.map({ $0.promptContent })
    }
    var allLoaded: Bool {
        return !self.promptContentDataByEntryId.isEmpty && self.promptContentDataByEntryId.values.allSatisfy({ (data) -> Bool in
            data.loadingFinished
        })
    }
    
    override init() {
        super.init()
    }
    
    
    func index(entryId: String) -> Int? {
        return self.result?.results?.firstIndex(where: { (content) -> Bool in
            return content.entryId == entryId
        })
    }
    
    func initDataObjects() {
        self.result?.results?.forEach { promptContent in
            guard let entryId = promptContent.entryId else {
                return
            }
            if self.promptContentDataByEntryId[entryId] == nil {
                self.logger.debug("Setting up prompt content entry data source for promptId \(entryId)")
                self.promptContentDataByEntryId[entryId] = PromptContentData(promptContent, delegate: self)
            }
            
            let data = self.promptContentDataByEntryId[entryId]
            data?.promptContent = promptContent
            data?.delegate = self
        }
    }
    
    func updateOrderedData() {
        self.orderedPromptData = self.result?.results?.compactMap { (promptContent) -> PromptContentData? in
            guard let entryId = promptContent.entryId else {
                return nil
            }
            let data = self.promptContentDataByEntryId[entryId]
            return data
        }
    }
    
    func handlePageResult(_ pageResult: PageResult<PromptContent>) {
        //Update the ordered list to get the added and removed indexes
        self.initDataObjects()
        
        if self.allLoaded {
            self.updateOrderedData()
            self.delegate?.pageUpdated(removed: pageResult.removed, added: pageResult.added, updated: pageResult.updated)
        }
    }
    
    //MARK: PromptContentDelegate
    func promptContentDataLoaded(promptContentData: PromptContentData) {
        self.logger.info("Prompt content data finished loading for entry: \(promptContentData.promptContent.entryId ?? "unknown"). Num responses = \(promptContentData.responseData.responses.count)")
        guard let entryId = promptContentData.promptContent.entryId else {
            self.logger.error("No entry ID found on the prompt content data")
            return
        }
        self.promptContentDataByEntryId[entryId] = promptContentData
        
        if self.allLoaded {
            self.updateOrderedData()
            self.delegate?.pageLoader(pageLoader: self, loadingFinished: true)
        }
    }
}
