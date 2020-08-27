//
//  JournalEmptyStateView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons

struct JournalEmptyStateView: View {
   enum Sheet: Identifiable {
        case onboardingPrompt(JournalEntry)
        
        var id: Int {
            switch self {
            case .onboardingPrompt:
                return 0
            }
        }
    }
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    @State var currentSheet: Sheet?
    var onboardingEntry: JournalEntry?
    
    var entry: JournalEntry? {
        self.session.onboardingEntry
    }
    
    var loading: Bool {
        !self.session.onboardingEntryLoaded
    }
    
    
    func getSheetView(item: Sheet) -> AnyView {
        switch item {
        case .onboardingPrompt(let entry):
            return PromptContentView(entry: entry).eraseToAnyView()
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center, spacing: Spacing.small) {
                        Spacer(minLength: Spacing.xlarge)
                        Image(IconType.journal.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(NamedColor.Magenta.color)
                        
                        Text("This is your journal.")
                            .font(CactusFont.bold(.large))
                            .foregroundColor(named: .TextDefault)
                        Text("It's a little empty now, but once you complete your first question your journal entries will appear here.")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(named: .TextDefault)
                        if self.entry != nil {
                            CactusButton("Get Started", .buttonPrimary)
                                .padding(.top, Spacing.normal)
                                .onTapGesture() {
                                    self.currentSheet = .onboardingPrompt(self.entry!)
                                }
                        }
                        Spacer(minLength: Spacing.normal)
                    }
                    .padding([.top, .leading, .trailing], Spacing.large)
                    Spacer()
                }
                .minHeight(geo.size.height)
    //            .padding(Spacing.normal)
            }
            .sheet(item: self.$currentSheet) { item in
                self.getSheetView(item: item)
                    .environmentObject(self.session)
                    .environmentObject(self.checkout)
        }
        }
    }
}

struct JournalEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEmptyStateView()
        .environmentObject(SessionStore.mockLoggedIn())
        .environmentObject(CheckoutStore.mock())
    }
}
