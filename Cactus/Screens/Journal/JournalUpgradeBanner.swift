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
    @EnvironmentObject var checkout: CheckoutStore
    @State var showPricing = false
    
    var copy: JournalBannerCopy? {
        return SubscriptionCopy.journalBannerText(self.session.member, settings: self.session.settings)
    }
    
    var title: String? {
        self.copy?.title
    }
    
    var description: String? {
        self.copy?.description
    }
    
    var buttonText: String {
        self.copy?.buttonText ?? "Try it free"
    }
    
    var paddingTop: CGFloat = 0
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.normal) {
                VStack(alignment: .leading, spacing: 0) {
                    if self.title != nil {
                        Text(self.title!)
                        .font(Font(CactusFont.normalBold))
                        .foregroundColor(Color.white)
                    }
                    
                    if self.description != nil {
                        Text(self.description!)
                        .font(Font(CactusFont.normal))
                        .foregroundColor(Color.white)
                    }
                }
                
                CactusButton(self.buttonText, .buttonPrimary, disableBorder: true)
                    .onTapGesture {
                        self.showPricing = true
                }
            }
            Spacer()
        }
        .padding(Spacing.normal)
        .background(Image(CactusImage.plusBg.rawValue)
        .background(CactusColor.indigo.color), alignment: .top)
//        .clipped()
        .cornerRadius(CornerRadius.normal)
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: self.$showPricing) {
            PricingView().environmentObject(self.session)
                .environmentObject(self.checkout)
        }
    }
    
}

struct JournalUpgradeBanner_Previews: PreviewProvider {
    static var previews: some View {
        JournalUpgradeBanner(paddingTop: 40)
            .environmentObject(SessionStore.mockLoggedIn(tier: .BASIC))
            .environmentObject(CheckoutStore.mock())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
