//
//  SubscriptionSettingsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import Purchases

struct LegacySubscriptionSettingsViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ManageSubscriptionViewController
    
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> ManageSubscriptionViewController {
        let vc = ScreenID.ManageSubscription.getViewController() as! ManageSubscriptionViewController
        vc.member = session.member
        vc.upgradeCopy = session.settings?.upgradeCopy
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ManageSubscriptionViewController, context: Context) {
        uiViewController.member = session.member
        uiViewController.upgradeCopy = session.settings?.upgradeCopy
    }
}

enum SubscriptionActionSheet {
    case restorePurchases
}

struct SubscriptionSettingsView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    @ObservedObject var data: SubscriberData =  SubscriberData(autoFetch: false)
    @State var showPricing: Bool = false
    @State var showActionSheet: Bool = false
    @State var currentActionSheet: SubscriptionActionSheet?
    
    var logger = Logger("SubscriptionSettingsView")
    var plusEntitlement: RevenueCat.EntitlementInfo? {
        self.data.purchaserInfo?.entitlements.all[SubscriptionTier.PLUS.rawValue]
    }
    
    var tier: SubscriptionTier {
        self.session.member?.tier ?? .BASIC
    }
    
    var tierName: String {
        self.tier.displayName
    }
    
    var showUpgradeButton: Bool {
        return self.tier < .PLUS
    }
    
    var rcIdentity: String {
        return Purchases.shared.appUserID
    }
    
    var storeName: String {
        guard let store = self.plusEntitlement?.store else {
            return "Unknown"
        }
        
        return BillingPlatform.fromStore(store).displayName
    }
    
    var periodType: String? {
        switch self.plusEntitlement?.periodType {
        case .intro:
            return "Introductory Pricing"
        case .trial:
            return "Free Trial"
        case .normal:
            return "Normal"
        case .none:
            return "None"
        default:
            return nil
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView(width: geometry.size.width, height: geometry.size.height, handlePullToRefresh: {
                self.data.fetch()
            }) {
                VStack(alignment: .leading, spacing: Spacing.xlarge) {
                    SubscriptionDetailsView(model: SubscriptionDetailsViewModel.fromSubscriberData(self.data, member: self.session.member))
                    if self.data.hasLoaded {
                      
                        if self.showUpgradeButton {
                            CactusButton("Try Cactus Plus", .buttonPrimary).onTapGesture {
                                self.showPricing = true
                            }
                        }
                        
                        CactusButton("Restore Purchases", .link).onTapGesture {
                            self.currentActionSheet = .restorePurchases
                            self.showActionSheet = true
                        }
                    } //end loading conditional
                } //end vstack
                    .padding()
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: 0,
                           maxHeight: .infinity,
                           alignment: .topLeading
                )               
            }
            
        } //end geometry reader
        .onAppear {
            self.data.fetch()
        }
            .sheet(isPresented: self.$showPricing) {
                PricingView().environmentObject(self.session)
                    .environmentObject(self.checkout)
        } //end sheet
            
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
    } //end body
} // end View

struct SubscriptionSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
            SubscriptionSettingsView()
                .navigationBarTitle("Subscription")
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock())
            }
            
            NavigationView {
            SubscriptionSettingsView()
                .navigationBarTitle("Subscription")
                .environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .environmentObject(CheckoutStore.mock())
                
            }
            .colorScheme(.dark)
        }
    }
}
