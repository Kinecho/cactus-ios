//
//  PromptCardsView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/3/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import SwiftUIX

struct PromptCardsView: View {
    @EnvironmentObject var session: SessionStore
    @State var currentPage: Int = 0
    let entry: JournalEntry
    var cards: [Card] {
        ContentCardViewModel.createAll(self.entry, member: self.session.member)
    }
    
    init(_ entry: JournalEntry) {
        self.entry = entry    
    }
    
    var pages: [CardView] {
        self.cards.map { card in
            CardView(card: card)
        }
    }
    
    var controllers: [UIViewController] {
        self.pages.map({ UIHostingController(rootView: $0) })
    }
    
    var body: some View {
        ZStack {
            PageViewController(controllers: self.controllers, currentPage: self.$currentPage)
            PageControl(numberOfPages: self.controllers.count, currentPage: self.$currentPage)
                            .padding(.trailing)
        }
        
    }
}

struct PromptCardsView_Previews: PreviewProvider {
    static var previews: some View {
        PromptCardsView(MockData.getAnsweredEntry())
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//            .frame(width: 400, height: 400)
//            .fixedSize(horizontal: false, vertical: true)
            .environmentObject(SessionStore.mockLoggedIn())
            .previewDevice("iPhone 11")
    }
}
