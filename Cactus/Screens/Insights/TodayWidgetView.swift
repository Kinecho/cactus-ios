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
                    Text("Uh oh")
                        .multilineTextAlignment(.center)
                        .font(CactusFont.bold(.title).font)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("There seems to be an issue finding today's prompt. Please check back a little later.")
                        .multilineTextAlignment(.center)
                        .font(CactusFont.normal.font)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .foregroundColor(named: .TextDefault)
                .padding()
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
        }.border(NamedColor.BorderLight.color, cornerRadius: CornerRadius.normal, style: .continuous, width: 1)
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetView().environmentObject(SessionStore.mockLoggedIn())
    }
}
