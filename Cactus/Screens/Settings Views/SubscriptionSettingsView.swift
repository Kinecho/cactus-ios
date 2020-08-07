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

struct SubscriptionSettingsView: View {
    @ObservedObject var data = SubscriberData()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    @State var showPricing: Bool = false
    
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
        //        LegacySubscriptionSettingsViewController()=
        
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Spacing.normal) {
                SubscriptionDetailsView(model: SubscriptionDetailsViewModel.fromSubscriberData(data, member: self.session.member))
                CactusButton("Refresh", .buttonSecondary)
                    .onTapGesture {
                        self.logger.info("Fake fetch")
                        self.data.fetch()
                    }
                
                if self.showUpgradeButton {
                    CactusButton("Try Cactus Plus", .buttonPrimary).onTapGesture {
                        self.showPricing = true
                    }
                }
                
//                VStack(alignment: .leading) {
//                    Text("Subscription Invoice Details").font(.headline)
//                    if !self.data.detailsLoaded {
//                        HStack {
//                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
//                            Text("Loading SubscriptoinDetail")
//                        }
//                    } else {
//                        Text("Invoice Status: \(self.data.subscriptionDetails?.upcomingInvoice?.status?.rawValue ?? "No status")")
//                    }
//                }
                
                
                
//                VStack(alignment: .leading) {
//                    Text("RevenueCat Details").font(.headline)
//
//                    if !self.data.purchaserInfoLoaded {
//                        HStack {
//                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
//                            Text("Loading RevenueCat Info")
//                        }
//                    } else if self.plusEntitlement != nil {
//                        Group {
//                            Text("RCID: \(self.rcIdentity)")
//                            Text("Subscritpion Status: \(self.plusEntitlement!.isActive ? "Active" : "Not Active")")
//                            Text("Will Renew: \(self.plusEntitlement!.willRenew ? "Yes" : "No")")
//                            Text("In Trial: \(self.plusEntitlement!.periodType == .trial ? "In Trial" : "Not in trial")")
//                            Text("Period Type: \(self.periodType ?? "--")")
//                        }
//                        Group {
//                            Text("Original Purchase Date \(FormatUtils.localizedDate(self.plusEntitlement!.originalPurchaseDate, dateStyle: .short, timeStyle: .medium) ?? "Unknown")")
//                            Text("Last Purchase Date \(FormatUtils.localizedDate(self.plusEntitlement!.latestPurchaseDate, dateStyle: .short, timeStyle: .medium) ?? "Unknown")")
//                            Text("Expiration Date \(FormatUtils.localizedDate(self.plusEntitlement!.expirationDate, dateStyle: .short, timeStyle: .none) ?? "Unknown")")
//                            Text("Unsubscribed At \(FormatUtils.localizedDate(self.plusEntitlement!.unsubscribeDetectedAt) ?? "none")")
//                            Text("Billing Issue Detected At (may be delayed) \(FormatUtils.localizedDate(self.plusEntitlement!.billingIssueDetectedAt) ?? "--")")
//                            Text("Billing Store: \(self.storeName)")
//                        }
//                    } else {
//                        Text("No entitlements")
//                    }
//
//                }
                
            }
            .onAppear {
                DispatchQueue.main.async {
                    self.data.fetch(nil)
                }
            }
            .padding()
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   minHeight: 0,
                   maxHeight: .infinity,
                   alignment: .topLeading
            )
        }
        .sheet(isPresented: self.$showPricing) {
            PricingView().environmentObject(self.session)
                .environmentObject(self.checkout)
        }
    }
}

struct SubscriptionSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubscriptionSettingsView()
            .environmentObject(SessionStore.mockLoggedIn())
            .environmentObject(CheckoutStore.mock())
    }
}
