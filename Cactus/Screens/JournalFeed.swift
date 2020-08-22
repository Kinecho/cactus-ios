//
//  JournalFeed.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

class JournalFeedPromptDelegate: ObservableObject, PromptContentPageViewControllerDelegate {
    let logger = Logger("JournalFeedPromptDelegate")
    
    @Published var showNotificationsOnboarding: Bool = false
    
    func didDismissPrompt(promptContent: PromptContent) {
        self.logger.info("Prompt was dismissed")
        self.showNotificationsOnboarding = true
    }
}

struct JournalFeed: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    //swiftlint:disable:next weak_delegate
    @ObservedObject var promptDelegate = JournalFeedPromptDelegate()
    
    var entries: [JournalEntry] {
        session.journalEntries
    }
    
    @State var selectedEntry: JournalEntry?
    @State var isPresenting: Bool = false
    @State var showDetail: Bool = false
    @State var showNotificationOnboarding: Bool = false
    @State var notificationAuthorizationStatus: UNAuthorizationStatus?
    
    func handleEntrySelected(_ entry: JournalEntry) {
        if entry.promptContent != nil {
            self.selectedEntry = entry
            self.showDetail = true
            self.isPresenting = true
        } else {
            self.selectedEntry = nil
            self.showDetail = false
            self.isPresenting = false
        }
    }
    
    func onPromptDismiss(_ promptContent: PromptContent) {
        Logger.shared.info("Parent on dismiss for emtry \(promptContent.entryId ?? "no id")")
        self.selectedEntry = nil
        self.presentPermissionsOnboardingIfNeeded()
    }
    
    func presentPermissionsOnboardingIfNeeded() {
        guard self.entries.count > 0 else {
            return
        }
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKey.notificationOnboarding)
        if hasSeenOnboarding {
            return
        }
        
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                guard status != .authorized else {
                    return
                }
            
                self.notificationAuthorizationStatus = status
                self.showNotificationOnboarding = true
                self.isPresenting = true
            }
        }
    }
    
    var body: some View {
        List {
            if self.session.member?.tier == .BASIC {
                JournalUpgradeBanner()
            }
    
            ForEach(self.entries) { entry in
                JournalEntryRow(
                    entry: entry,
                    index: self.entries.firstIndex(of: entry) ?? 0,
                    showDetails: self.handleEntrySelected
                )
                    .onAppear {
                        let lastEntry = self.entries.last
                        if lastEntry?.id == entry.id {
                            self.session.journalFeedDataSource?.loadNextPage()
                        }
                    }
                    .onTapGesture {
                        self.handleEntrySelected(entry)
                    }
            }
            .padding()
            .padding(.bottom, Spacing.large)
            .listRowInsets(EdgeInsets())
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
//            UITableView.appearance().backgroundColor = CactusColor.background
//            UITableViewCell.appearance().backgroundColor = CactusColor.background
        })
        .sheet(isPresented: self.$isPresenting) {
            if self.showDetail && self.selectedEntry != nil {
                PromptContentView(entry: self.selectedEntry!, onPromptDismiss: self.onPromptDismiss).environmentObject(self.session)
            } else if self.showNotificationOnboarding {
                NotificationsOnboardingView(status: self.notificationAuthorizationStatus)
            }
        }
    }
}

struct JournalFeed_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC).setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Basic User")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC).setEntries(MockData.getDefaultJournalEntries()))
            .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
            .previewDisplayName("Basic User (Dark)")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC).setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Basic User - iPhone 5s")
                .previewDevice("iPhone SE")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS).setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Plus User")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS).setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
                .previewDisplayName("Plus User (Dark)")
            
            NavigationView {
                JournalFeed()
                    .navigationBarTitle("Journal")
                
            }
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS).setEntries(MockData.getDefaultJournalEntries()))
            .environmentObject(CheckoutStore.mock())
            .colorScheme(.dark)
            .previewDisplayName("Plus User NavigationWrapped (Dark)")
        }
    }
}
