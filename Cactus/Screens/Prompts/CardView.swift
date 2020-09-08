//
//  CardView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var session: SessionStore
    
    var card: Card
    
    var cardBody: some View {
        Group {
            switch self.card {
            case .text(let model):
                TextCardView(model: model)
            case .reflect(let model):
                ReflectCardView(model: model)
            default:
                Text("\(self.card.displayName) Card is not supported yet")
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                self.cardBody
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: geo.size.height, maxHeight: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }.background(named: .CardBackground)
            .fixedSize(horizontal: false, vertical: true)
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: geo.size.height, maxHeight: .infinity)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static let entry = MockData.getAnsweredEntry()
    
    static var previews: some View {
        Group {
            ForEach(ContentCardViewModel.createAll(entry, member: nil)) {card in
                PreviewHelperView(name: "\(card.displayName) Card") {
                    CardView(card: card)
                    .environmentObject(SessionStore.mockLoggedIn())
                }
            }
        }
    }
}
