//
//  AppEmptyState.swift
//  Cactus
//
//  Created by Neil Poulin on 8/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct HomeEmptyState: View {
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
                        Text("Welcome to Cactus")
                            .font(CactusFont.bold(.large))
                            .foregroundColor(named: .TextDefault)
                        Text("To get started, you'll learn about how Cactus works and reflect on your first question of the day.")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(named: .TextDefault)
                        
                        Image(CactusImage.emptyState.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 200)
                        
                        if self.entry != nil {
                            CactusButton("Get Started", .buttonPrimary).onTapGesture() {
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

struct HomeEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        HomeEmptyState()
            .environmentObject(SessionStore.mockLoggedIn())
            .environmentObject(CheckoutStore.mock())
    }
}
