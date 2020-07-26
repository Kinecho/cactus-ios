//
//  SessionStore.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

typealias PendingAction = (_ member: CactusMember?) -> Void

final class SessionStore: ObservableObject {
    @Published var authLoaded = false
    @Published var member: CactusMember?
    @Published var user: FirebaseUser?
    @Published var settings: AppSettings?
    @Published var useImagePlaceholders: Bool = false
    static var shared = SessionStore()
    
    var pendingAuthActions: [PendingAction] = []
    var settingsObserver: ListenerRegistration?
    var memberUnsubscriber: Unsubscriber?
    var journalFeedDataSource: JournalFeedDataSource?
    
    @Published var journalEntries: [JournalEntry] = []
    @Published var journalLoaded = false
    
    let logger = Logger("SessionStore")
    
    func start() {
        self.settingsObserver = AppSettingsService.sharedInstance.observeSettings { (settings, error) in
            if let error = error {
                self.logger.error("Failed to get app settings and can not start the app properly.", error)
            }
            self.settings = settings
            self.logger.info("***** setting up auth *****")
            self.setupAuth()
        }
        
        self.addAuthAction { (member) in
            guard let member = member else {
                return
            }
            
            let feed = JournalFeedDataSource.init(member: member, appSettings: self.settings)
            self.journalFeedDataSource = feed
            feed.delegate = self
            feed.start()
        }
    }
    
    func setupAuth() {
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember { (member, _, user) in
            self.logger.info("setup auth onData \(member?.email ?? "no email")" )
            
//            if member == nil && user == nil {
//                self.logger.info("found member is null. showing loign screen.")
//                self.showWelcomeScreen()
//            } else if member == nil && user != nil {
//                self.logger.info("User is logged in but no member was found (yet). We're probably still creating the member. Don't do anything!")
//            } else if let member = member, member.id != self.member?.id {
//                self.logger.info("Found member, not null. showing journal home page")
//                CactusAnalytics.shared.setSubscriptionTier(member: member)
//                self.showJournalHome(member: member, wrapInNav: true)
//            }
            self.member = member
            self.user = user
            self.authLoaded = true
//            self.runPendingActions()
            self.runPendingAuthActions()
        }
    }
    
    
    func setEntries(_ entries: [JournalEntry], loaded: Bool=true) -> SessionStore {
        self.journalEntries = entries
        self.journalLoaded = loaded
        return self
    }
    
    func runPendingAuthActions() {
        guard let member = self.member else {
            return
        }
        while !self.pendingAuthActions.isEmpty {
            let action = self.pendingAuthActions.removeFirst()
            action(member)
        }
    }
    
    func addAuthAction(_ action: @escaping PendingAction) {
        self.pendingAuthActions.append(action)
        self.runPendingAuthActions()
    }
    
    func stop() {
        self.settingsObserver?.remove()
        self.memberUnsubscriber?()
    }
}

extension SessionStore {
    static func mockLoggedIn(tier: SubscriptionTier = .BASIC) -> SessionStore {
        let store = SessionStore()
        
        store.settings = nil
        store.authLoaded = true
        let member = CactusMember()
        member.email = "test@cactus.app"
        member.id = "test123"
        member.tier = tier
        store.member = member
        
        return store
    }
    
    static func mockLoggedOut() -> SessionStore {
           let store = SessionStore()
           
           store.settings = nil
           store.authLoaded = true
           
           return store
       }
}




extension SessionStore: JournalFeedDataSourceDelegate {
    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
        guard let index = at ?? self.journalFeedDataSource?.indexOf(journalEntry) ?? self.journalEntries.firstIndex(of: journalEntry) else {
            return
        }
        self.journalEntries[index] = journalEntry
    }
    
    func insert(_ journalEntry: JournalEntry, at: Int?) {
        guard let index = at else {
            return
        }
        
        self.journalEntries[index] = journalEntry
    }
    
    func removeItems(_ indexes: [Int]) {
        self.journalEntries.remove(atOffsets: IndexSet(indexes))
    }
    
    func insertItems(_ indexes: [Int]) {
        indexes.forEach { (index) in
            guard let journalEntry = self.journalFeedDataSource?.get(at: index) else {
                return
            }
            self.journalEntries.insert(journalEntry, at: index)
            self.logger.info("Added entry at \(index)")
        }
        self.logger.info("after insert, there are \(self.journalEntries.count) entries")
    }
    
    func batchUpdate(addedIndexes: [Int], removedIndexes: [Int]) {
        self.removeItems(removedIndexes)
        self.insertItems(addedIndexes)
    }
    
    func dataLoaded() {
        let entries: [JournalEntry] = self.journalFeedDataSource?
            .orderedPromptIds
            .compactMap({self.journalFeedDataSource?.journalEntryDataByPromptId[$0]?.getJournalEntry()}) ?? []
        
        self.journalEntries = entries
    }
    
    func handleEmptyState(hasResults: Bool) {
        self.journalLoaded = true
        if hasResults == false {
            self.journalEntries = []
        }
    }
}
