//
//  PricingView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import Purchases

struct PricingController: UIViewControllerRepresentable {
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> PricingViewController {
        let vc = ScreenID.Pricing.getViewController() as! PricingViewController
        vc.appSettings = session.settings
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PricingViewController, context: Context) {
        uiViewController.appSettings = session.settings
    }
}

struct PricingView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    
    var showLoading: Bool {
        return !checkout.productGroupData.allLoaded
    }
    
    var plusProductsEntries: [ProductEntry] {
        guard let map = checkout.productGroupData.subscriptionProductGroupEntryMap else {
            return []
        }
        return map[SubscriptionTier.PLUS]?.products ?? []
    }
    
    var plusGroup: SubscriptionProductGroup? {
        return checkout.productGroupData.productGroups?.first {$0.subscriptionTier == .PLUS}
    }
    
    var footer: ProductGroupFooter? {
        return self.plusGroup?.footer
    }
    
    var subscriptionProducts: [SubscriptionProduct] {
        return self.checkout.productGroupData.subscriptionProducts ?? []
    }
    
    var packages: [Purchases.Package] {
        return self.checkout.productGroupData.rcPackages ?? []
    }
    
    var skProducts: [SKProduct] {
        return self.checkout.productGroupData.rcPackages?.map {$0.product} ?? []
    }
    
    var pageTitle: String {
        return "Get more with Cactus Plus"
    }
    
    var pageSubTitle: String {
        return "Get daily prompts, personalized questions, and more."
    }
    
//    var offerings: [Purchases.Offering] {
//        return self.checkout.productGroupData.rcPackages?.map {$0.}
//    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.normal) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: Spacing.small) {
                    Text(self.pageTitle)
                        .font(CactusFont.bold(FontSize.large).font)
                        .multilineTextAlignment(.center)
                    Text(pageSubTitle)
                        .multilineTextAlignment(.center)
                    
                }.padding(.vertical, Spacing.large)
                .padding(Spacing.large)
                Spacer()
            }
            .font(CactusFont.normal.font)
            .foregroundColor(CactusColor.white.color)
            .background(CactusImage.plusBg.swiftImage
                .resizable()
            .transformEffect(.init(scaleX: 1.0, y: 1.05))
                .scaledToFill()
            )
            
            HStack {
                Spacer()
                VStack {
                    Text("Plus Products (\(self.subscriptionProducts.count)):")
                        .font(CactusFont.bold(22).font)
                    ForEach(self.subscriptionProducts) { product in
                        Text(product.displayName)
                    }
                }
                Spacer()
            }
            .padding()
//            .background(Color.orange)
            
             
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.normal) {
                    Text("RevenueCat Packages (\(self.packages.count)):")
                        .font(CactusFont.bold(22).font)
                    ForEach(self.packages, id: \.identifier) { package in
                        VStack {
                            Text("Package Type \((package as Purchases.Package).packageType.rawValue)")
                            Text((package as Purchases.Package).localizedPriceString)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.5))
            
            Text("Product Groups (\(self.checkout.productGroupData.productGroups?.count ?? 0))")
            if self.footer != nil {
                HStack(alignment: .center, spacing: Spacing.normal) {
                    Spacer()
                    if Icon.getImage(self.footer?.icon) != nil {
                        Image(uiImage: Icon.getImage(self.footer?.icon)!)
                            .resizable()
                            .frame(width: 18, height: 18)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(CactusColor.textDefault.color)
                    }
                    if self.footer?.textMarkdown != nil {
                        MDText(markdown: self.footer!.textMarkdown!).offset(x: 0, y: -4)
                        .font(Font(CactusFont.normal))
                        .foregroundColor(Color(CactusColor.textDefault))
                    }
                    Spacer()
                }
                .padding()
                .background(Color.yellow)
            }
            Spacer()
        }
        .font(Font(CactusFont.normal))
        .background(CactusColor.background.color)
    }
}

struct PricingView_Previews: PreviewProvider {
    static var previews: some View {
        PricingView()
            .environmentObject(SessionStore.mockLoggedIn())
            .environmentObject(CheckoutStore.mock(loading: false))
    }
}
    
