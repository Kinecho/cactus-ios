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
    @EnvironmentObject var session: SessionStore
    
    var data: SubscriberData {
        self.session.subscriberData
    }
    
    var plusEntitlement: RevenueCat.EntitlementInfo? {
        self.data.purchaserInfo?.entitlements.all[SubscriptionTier.PLUS.rawValue]
    }
    
    var store: String {
        guard let store = self.plusEntitlement?.store else {
            return "Unknown"
        }
        
        return BillingPlatform.fromStore(store).displayName
    }
    
    var body: some View {
        //        LegacySubscriptionSettingsViewController()=
        
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Spacing.normal) {
                Text("Data Status: \(self.data.hasLoaded ? "Loaded" : "Loading")")
                
                
                Button("Refresh") {
                    self.data.fakeFetch()
                }
                
                
                VStack(alignment: .leading) {
                    Text("Subscription Invoice Details").font(.headline)
                    if !self.data.detailsLoaded {
                        HStack {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            Text("Loading SubscriptoinDetail")
                        }
                    } else {
                        Text("Invoice Status: \(self.data.subscriptionDetails?.upcomingInvoice?.status?.rawValue ?? "No status")")
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("RevenueCat Details").font(.headline)
                    
                    if !self.data.purchaserInfoLoaded {
                        HStack {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            Text("Loading RevenueCat Info")
                        }
                    } else if self.plusEntitlement != nil {
                        Text("Subscritpion Status: \(self.plusEntitlement!.isActive ? "Active" : "Not Active")")
                        Text("Will Renew: \(self.plusEntitlement!.willRenew ? "Yes" : "No")")
                        Text("In Trial: \(self.plusEntitlement!.periodType == .trial ? "In Trial" : "Not in trial")")
                        Text("Original Purchase Date \(FormatUtils.localizedDate(self.plusEntitlement!.originalPurchaseDate, dateStyle: .short, timeStyle: .medium) ?? "Unknown")")
                        Text("Expiration Date \(FormatUtils.localizedDate(self.plusEntitlement!.expirationDate, dateStyle: .short, timeStyle: .none) ?? "Unknown")")
                        Text("Store: \(self.store)")
                    } else {
                        Text("No entitlements")
                    }
                    
                }
                
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
    }
}

struct SubscriptionSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubscriptionSettingsView().environmentObject(SessionStore.mockLoggedIn())
    }
}
