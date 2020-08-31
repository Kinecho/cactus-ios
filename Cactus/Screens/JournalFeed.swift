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
    enum CurrentSheet: Identifiable {
        case notificationOnboarding
        case promptDetail(JournalEntry)
        
        var id: Int {
            switch self {
            case .notificationOnboarding:
                return 0
            case .promptDetail:
                return 1
            }
        }
        
        var journalEntry: JournalEntry? {
            switch self {
            case .promptDetail(let entry):
                return entry
            default:
                return nil
            }
        }
    }
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    
    //swiftlint:disable:next weak_delegate
    @ObservedObject var promptDelegate = JournalFeedPromptDelegate()
    
    var entries: [JournalEntry] {
        session.journalEntries
    }
    
    @State var selectedEntry: JournalEntry?
    @State var notificationAuthorizationStatus: UNAuthorizationStatus?
    @State var currentSheet: CurrentSheet?
    
    func handleEntrySelected(_ entry: JournalEntry) {
        if entry.promptContent != nil {
            Vibration.selection.vibrate()
            self.selectedEntry = entry
            self.currentSheet = .promptDetail(entry)
        } else {
            self.selectedEntry = nil
            self.currentSheet = nil
        }
    }
    
    func onPromptDismiss(_ promptContent: PromptContent) {
        Logger.shared.info("Parent on dismiss for emtry \(promptContent.entryId ?? "no id")")
        self.currentSheet = nil
        self.selectedEntry = nil
        self.presentPermissionsOnboardingIfNeeded()
    }
    
    func presentPermissionsOnboardingIfNeeded() {
        guard self.entries.count > 0 else {
            self.currentSheet = nil
            return
        }
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKey.notificationOnboarding)
        if hasSeenOnboarding {
            self.currentSheet = nil
            return
        }
        
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                guard status != .authorized else {
                    self.currentSheet = nil
                    return
                }
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.notificationOnboarding)
                self.notificationAuthorizationStatus = status
                self.currentSheet = .notificationOnboarding
            }
        }
    }
    
    var cellBackgroundColor: Color {
        if #available(iOS 14, *) {
            return Color.systemBackground
        } else {
            return NamedColor.WhiteInvertable.color
        }
    }
    
    
    func getSheetContent(_ item: CurrentSheet) -> AnyView {
        switch item {
        case .promptDetail(let entry):
            return PromptContentView(entry: entry,
                                     onPromptDismiss: self.onPromptDismiss)
                .environmentObject(self.session)
                .environmentObject(self.checkout)
                .eraseToAnyView()
        case .notificationOnboarding:
            return NotificationsOnboardingView(status: self.notificationAuthorizationStatus)
                .environmentObject(self.session)
                .environmentObject(self.checkout)
                .eraseToAnyView()
        }
    }
    
    func onEntryAppeared(_ entry: JournalEntry) {
        if self.entries.last?.id == entry.id {
            self.session.journalFeedDataSource?.loadNextPage()
        }
    }
    
    var body: some View {
        List {
            Group {
                if self.session.member?.tier == .BASIC {
                    JournalUpgradeBanner()
                        .padding(.all, Spacing.normal)                    
                        .listRowInsets(EdgeInsets())
                        .background(self.cellBackgroundColor)
                }
        
                ForEach(self.entries) { entry in
                    JournalEntryRow(
                        entry: entry,
                        index: self.entries.firstIndex(of: entry) ?? 0,
                        showDetails: self.handleEntrySelected
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .onAppear { self.onEntryAppeared(entry) }
                    .onTapGesture { self.handleEntrySelected(entry) }
                    .padding(.top, Spacing.medium)
                    .padding(.bottom, Spacing.normal)
                }
                .padding(.horizontal, Spacing.normal)
                .listRowInsets(EdgeInsets())
                .background(Color.systemBackground)
            }
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
        })
        .sheet(item: self.$currentSheet ) { item in
            self.getSheetContent(item)
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
