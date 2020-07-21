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
//            .padding()
            .listRowInsets(EdgeInsets())
                .padding(30)
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
            MockData.journalEntry(id: "one", content: [MockData.content("Promt Content Question Text 1")], loaded: false),
            MockData.journalEntry(id: "two", content: [MockData.content("Second Promt Content Question Text with **really really bold** text in the second sentence. And if it keeps going and going, the entry keeps getting taller and taller!")], loaded: false),
            MockData.journalEntry(id: "three", content: [MockData.content("Third question text")], loaded: true)
        ]
        return session
    }
     
    static var previews: some View {
        JournalFeed().environmentObject(self.getSession())
    }
}
