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
            Text("\(session.member?.email ?? "My") Journal Entries")
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
    
    static func getSession() -> SessionStore {
        let session = SessionStore.mockLoggedIn()
        session.journalEntries = [
            MockData.getUnansweredEntry(isToday: true),
            MockData.getUnansweredEntry(isToday: false),
            MockData.EntryBuilder(question: "What do you think of SwiftUI?", answer: "This is a really thoughtful response.").build(),
            MockData.getLoadingEntry(),
        ]
        return session
    }
     
    static var previews: some View {
        JournalFeed().environmentObject(self.getSession())
    }
}
