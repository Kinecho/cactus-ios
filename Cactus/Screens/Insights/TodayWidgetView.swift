//
//  TodayWidgetView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct TodayWidgetView: View {
    @EnvironmentObject var session: SessionStore
    var onTapped: ((JournalEntry) -> Void)?
    
    var todayEntry: JournalEntry? {
        self.session.journalFeedDataSource?.todayData?.getJournalEntry()
    }
    
    var todayEntryLoaded: Bool {
        self.session.journalFeedDataSource?.todayLoaded ?? false
    }
    
    
    var body: some View {
        Group {
            if self.todayEntry != nil {
                JournalEntryRow(entry: self.todayEntry!, inlineImage: true).onTapGesture {
                    self.onTapped?(self.todayEntry!)
                }
            } else if self.todayEntryLoaded {
                VStack {
                    Text("Uh oh").font(CactusFont.bold(.title).font)
                    Text("There seems to be an issue finding today's prompt. Please check back a little later.")
                        .font(CactusFont.normal.font)
                }.foregroundColor(named: .TextDefault)
                    .background(named: .CardBackground)
                    .cornerRadius(CornerRadius.normal)
            } else {
                HStack(alignment: .center) {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    Text("Loading Today's Prompt")
                }
                .padding()
                .background(named: .CardBackground)
                .cornerRadius(CornerRadius.normal)
            }
        }
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetView().environmentObject(SessionStore.mockLoggedIn())
    }
}
