//
//  JournalFeed.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalFeed: View {    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    
    var entries: [JournalEntry] {
        session.journalEntries
    }
    
    @State var selectedEntry: JournalEntry?
    @State var showDetail: Bool = false
    
    func handleEntrySelected(entry: JournalEntry) {
        if entry.promptContent != nil {
            self.selectedEntry = entry
            self.showDetail = true
        } else {
            self.selectedEntry = nil
            self.showDetail = false
        }
    }
    
    var body: some View {
        List {
            if self.session.member?.tier == .BASIC {
                JournalUpgradeBanner()
                
//                .listRowInsets(EdgeInsets())
            }
    
            ForEach(self.entries) { entry in
                JournalEntryRow(entry: entry, index: self.entries.firstIndex(of: entry) ?? 0)
                    .onAppear {
                        Logger("JournalEntryRow on Appear").info("Journal entry will on appear")
                        let lastEntry = self.entries.last
                        if lastEntry?.id == entry.id {
                            self.session.journalFeedDataSource?.loadNextPage()
                        }
                }.onTapGesture {
                    self.handleEntrySelected(entry: entry)
                }
            }
            .padding()
            .padding(.bottom, Spacing.large)
            .listRowInsets(EdgeInsets())
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = CactusColor.background
            UITableViewCell.appearance().backgroundColor = CactusColor.background
        })
            .sheet(isPresented: self.$showDetail) {
                PromptContentView(entry: self.selectedEntry!).environmentObject(self.session)
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
        }
    }
}
