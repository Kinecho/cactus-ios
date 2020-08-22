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
                JournalEntryRow(entry: self.todayEntry!, inlineImage: true, backgroundColor: .clear).onTapGesture {
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
                .foregroundColor(named: .White)
                .padding()
//                .background(named: .CardBackground)
                .cornerRadius(CornerRadius.normal)
                
            } else {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        ActivityIndicator(isAnimating: .constant(true), style: .medium, color: NamedColor.White.color)
                        Text("Loading Today's Prompt")
                        Spacer()
                    }
                    .padding(.all, Spacing.large)
//                    .background(named: .CardBackground)
                    .cornerRadius(CornerRadius.normal)
                }
            }
        }
        .background(named: .TodayWidgetBackground)
        .foregroundColor(named: .White)
        .border(NamedColor.BorderLight.color, cornerRadius: CornerRadius.normal, style: .continuous, width: 1)
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    static let loadingData = SessionStore.mockLoggedIn()
    static func withData() -> SessionStore {
        let store = SessionStore.mockLoggedIn()
        let todayData = JournalEntryData(promptId: nil, memberId: store.member?.id ?? "test", journalDate: Date())
//        todayData.wontLoad = true
        store.journalFeedDataSource?.todayData = todayData
        return store
    }
    static var previews: some View {
        Group {
            TodayWidgetView()
                .environmentObject(loadingData)
                .previewDisplayName("Loading (Light))")
                .colorScheme(.light)
            
            TodayWidgetView()
                .environmentObject(withData())
                .previewDisplayName("Unanswered Prompt (Light))")
                .colorScheme(.light)
        }
        
    }
}
