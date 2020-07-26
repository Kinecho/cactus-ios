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
            }
            
            VStack(alignment: .leading) {
                Text("Email: \(self.session.member?.email ?? "no email")")
                Text("Tier: \((self.session.member?.tier ?? SubscriptionTier.BASIC).rawValue)")
            }
            
            ForEach(self.entries) { entry in
                JournalEntryRow(entry: entry)
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
            .listRowInsets(EdgeInsets())
        }
        .navigationBarHidden(true)
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
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
                .previewDisplayName("Basic User")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC).setEntries(MockData.getDefaultJournalEntries()))
                .previewDisplayName("Basic User - iPhone 5s")
                .previewDevice("iPhone SE")
            
            JournalFeed().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS).setEntries(MockData.getDefaultJournalEntries())).previewDisplayName("Plus User")
        }
    }
}
