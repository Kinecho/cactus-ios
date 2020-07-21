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
    
    var body: some View {
        List {
            Text("My Journal Entries")
            ForEach(self.entries) { entry in
                JournalEntryRow(entry: entry)                    
                    .onAppear {
                        Logger("JournalEntryRow on Appear").info("Journal entry will on appear")
                        let lastEntry = self.entries.last
                        if lastEntry?.id == entry.id {
                            self.session.journalFeedDataSource?.loadNextPage()
                        }
                    }
            }
            .padding()
            .listRowInsets(EdgeInsets())
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
        .edgesIgnoringSafeArea(.horizontal)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct JournalFeed_Previews: PreviewProvider {
    static func createEntry(_ id: String) -> JournalEntry {
        let entry = JournalEntry(promptId: id)
        
        return entry
    }
    
    static func getSession() -> SessionStore {
        let session = SessionStore.mockLoggedIn()
        session.journalEntries = [createEntry("one"), createEntry("two"), createEntry("two aldjaflskj aslfj sdalkjf dlafkj salfkj lfkajsdflakj lksdfj alkdfj laksj ")]
        return session
    }
    
    static var previews: some View {
        JournalFeed().environmentObject(self.getSession())
    }
}
