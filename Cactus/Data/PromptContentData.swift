//
//  PromptContentData.swift
//  Cactus
//
//  Created by Neil Poulin on 4/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

protocol PromptContentDataDelegate: class {
    func promptContentDataLoaded(promptContentData: PromptContentData)
}

class PromptContentData {
    var promptContent: PromptContent
    var memberId: String?
    var responseData = ResponseData()
    weak var delegate: PromptContentDataDelegate?
    var loadingFinished: Bool {
        return self.responseData.hasLoaded
    }
    init(_ promptContent: PromptContent, delegate: PromptContentDataDelegate? = nil) {
        self.promptContent = promptContent
        self.delegate = delegate
        self.listen()
    }
    
    func listen() {
        if let promptId = self.promptContent.promptId {
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
        }
    }
    
    deinit {
        self.stopAll()
    }
    
    func stopAll() {
        self.responseData.unsubscriber?.remove()
    }
    
    func notifyIfLoadingComplete() {
        if self.loadingFinished {
            self.delegate?.promptContentDataLoaded(promptContentData: self)
        }
    }
    
    static func == (lhs: PromptContentData, rhs: PromptContentData) -> Bool {
        return lhs.promptContent.entryId == rhs.promptContent.entryId                    
    }
}
