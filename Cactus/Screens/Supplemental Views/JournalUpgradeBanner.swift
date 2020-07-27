//
//  JournalUpgradeBanner.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalUpgradeBanner: View {
    @EnvironmentObject var session: SessionStore
    @State var showPricing = false
    
    var paddingTop: CGFloat = 0
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.normal) {
                Text("\(self.session.member?.email ?? "My") Journal Entries")
                    .font(Font(CactusFont.normal))
                    .foregroundColor(Color.white)
                CactusButton("Try it free", .buttonPrimary)
                    .onTapGesture {
                        self.showPricing = true
                }
            }
            Spacer()
        }
        .padding(Spacing.normal)
        .background(Image(CactusImage.plusBg.rawValue)
        .background(CactusColor.indigo.color), alignment: .top)
        .clipped()
        .cornerRadius(CornerRadius.normal)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: self.$showPricing) {
            PricingView().environmentObject(self.session)
        }
//        .actionSheet(isPresented: self.$showPricing) {
//            ActionSheet(title: Text("Pricing Page"),
//                        message: Text("Maybe we show one-click purchase options here..."),
//                        buttons: [
//                            .default(Text("Dismiss Action Sheet"))
//            ])
//        }
    }
    
}

struct JournalUpgradeBanner_Previews: PreviewProvider {
    static var previews: some View {
        JournalUpgradeBanner(paddingTop: 40)
            .environmentObject(SessionStore.mockLoggedIn(tier: .BASIC))
            .padding()
    }
}
