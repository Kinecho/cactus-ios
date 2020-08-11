//
//  PricingView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import Purchases
import SwiftUIX

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
    @State var selectedProductId: String?
    @State var showActionSheet: Bool = false
    var showLoading: Bool {
        return !checkout.productGroupData.allLoaded
    }
    
    var isSubscribed: Bool {
        self.session.member?.tier.isPaidTier ?? false
    }
    
    var selectedProduct: SKProduct? {
        let productId = self.defaultSelectedProductId
        return self.skProducts.first { $0.productIdentifier == productId }
    }
    
    var pricingSettings: PricingScreenSettings {
        self.session.settings?.pricingScreen ?? PricingScreenSettings.defaultSettings()
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
        return self.pricingSettings.pageTitleMarkdown
    }
    
    var pageSubTitle: String {
        return self.pricingSettings.pageDescriptionMarkdown
    }
    
    var features: [PricingFeature] {
        return self.pricingSettings.features
    }
    
    func isSelectedProduct(_ product: SKProduct) -> Bool {
        if let selectedId = self.selectedProductId {
            return selectedId == product.productIdentifier
        }
        let defaultPeriod = self.plusGroup?.defaultSelectedPeriod ?? BillingPeriod.yearly
        return  product.subscriptionPeriod?.billingPeriod == defaultPeriod
    }
    
    var defaultSelectedProductId: String? {
        if let selectedId = self.selectedProductId {
            return selectedId
        }
        let defaultPeriod = self.plusGroup?.defaultSelectedPeriod ?? BillingPeriod.yearly
        let defaultProduct = self.skProducts.first { $0.subscriptionPeriod?.billingPeriod == defaultPeriod }
        return defaultProduct?.productIdentifier
    }
    
    var checkoutButtonState: ButtonState {
        self.checkout.checkoutInProgress ? .loading : .normal
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: Spacing.normal) {
                VStack(alignment: .center, spacing: Spacing.normal) {
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: Spacing.small) {
                            Text(self.pageTitle)
                                .font(CactusFont.bold(FontSize.large).font)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(pageSubTitle)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
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
                
                
                    PlusFeaturesPagination(features: self.features, height: 250)
                        .height(250)
                        .pageIndicatorTintColor(NamedColor.GreenDarkest.color)
                        .currentPageIndicatorTintColor(NamedColor.Green.color)
                        .offset(x: 0, y: -20)
                        .padding(.bottom, -20)
                 }
                 .background(named: .Background)
                
                VStack {
                    if !self.isSubscribed {
                        HStack(alignment: .center, spacing: Spacing.normal) {
                            Spacer()
                            ForEach(self.skProducts, id: \.productIdentifier) { product in
                                BuyableItemView(model: BuyableItemViewModel.fromProduct(product),
                                                selected: self.isSelectedProduct(product))
                                    .foregroundColor(named: .White)
                                    .onTapGesture {
                                        self.selectedProductId = product.productIdentifier
                                    }
                                    
                            }
                            Spacer()
                        }
                        
                        if self.footer != nil {
                            VStack(alignment: .center) {
                                HStack(alignment: .center, spacing: Spacing.small) {
                                    
                                        if Icon.getImage(self.footer?.icon) != nil {
                                            Image(uiImage: Icon.getImage(self.footer?.icon)!)
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(named: .Magenta)
                                        }
                                        if self.footer?.textMarkdown != nil {
                                            Text(self.footer!.textMarkdown!)
                                                .font(Font(CactusFont.normal))
                                                .foregroundColor(Color(CactusColor.white))
                                        }
                                }
                                .padding()
                            }
                        }
                        Spacer()
                        CactusButton("Try Cactus Plus", .buttonPrimary, state: self.checkoutButtonState)
                            .onTapGesture {
                                if self.selectedProduct != nil {
                                    self.checkout.submitPurchase(self.selectedProduct!)
                                }
                            }
                        
                        CactusButton("Restore Purchases", .link).onTapGesture {
                            self.showActionSheet = true
                        }
                        
                    } else {
                        Text("Thank you for your support as a Cactus Plus customer.")
                            .multilineTextAlignment(.center)
                            .padding(Spacing.large)
                            .foregroundColor(NamedColor.White.color)
                    }
                    Spacer(minLength: Spacing.giant)
                }
                .padding()
                .background(named: .Dolphin)
            }
            .font(Font(CactusFont.normal))
                .edgesIgnoringSafeArea(.vertical)
        }
        .background(named: .Dolphin)
        .edgesIgnoringSafeArea(.vertical)
        .actionSheet(isPresented: self.$showActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Restore Purchases"),
                            message: Text("Any previous purchases with an active subscription will be restored. This may take a few minutes."),
                            buttons: [
                                .cancel(Text("Cacnel")),
                                .default(Text("Restore Purchases"), action: {
                                    self.checkout.restorePurchases()
                                })
                    ]
                )
        } //end action sheet
        
    }
}

struct PricingView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            PricingView()
                .environmentObject(SessionStore.mockLoggedIn())
                .environmentObject(CheckoutStore.mock(loading: false))
                .previewDisplayName("Pricing Page (Light)")
            
            PricingView()
                .environmentObject(SessionStore.mockLoggedIn())
                .environmentObject(CheckoutStore.mock(loading: false))
                .colorScheme(.dark)
                .previewDisplayName("Pricing Page (Dark)")
            
            
            PricingView()
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock(loading: false))
                .previewDisplayName("Already Subscribed (Light)")
            
            PricingView()
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock(loading: false))
                .colorScheme(.dark)
                .previewDisplayName("Already Subscribed (Dark)")
            
        }
    }
}
    
