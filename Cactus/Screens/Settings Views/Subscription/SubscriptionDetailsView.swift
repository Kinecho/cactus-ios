//
//  SubscriptionDetailsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/6/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import Purchases

struct SubscriptionDetailsViewModel: Identifiable {
    let id = UUID()
    
    /// The current tier of the member
    var tier: SubscriptionTier
    var loaded: Bool = true
    
    // MARK: RevenueCat fields
    var billingPlatform: BillingPlatform?
    var willRenew: Bool = false
    var isActive: Bool = true
    var periodType: Purchases.PeriodType = .normal
    var firstPurchaseDate: Date?
    var latestPurchaseDate: Date?
    var expirationDate: Date?
    var unsubscribeDetectedDate: Date?
    var billingIssueDetectedDate: Date?
    var skProductID: String?
    
    // MARK: Cactus Fields
    var ccLast4: String?
    var ccBrand: CardBrand?
    var nextAmountCentsUSD: Int?
    ///Formatted price
    var nextAmount: String?
    var trialDaysLeft: Int?
    
    var androidSku: String?
    var androidPackageName: String?
    
    
    var manageSubscriptionUrl: URL? {
        var url: URL?
        switch self.billingPlatform {
        case .APPLE:
            url = URL(string: "https://apps.apple.com/account/subscriptions")
        case .GOOGLE:
            let sku = self.androidSku ?? ""
            let packageName = self.androidPackageName ?? ""
            url = URL(string: "https://play.google.com/store/account/subscriptions?sku=\(sku)&package=\(packageName)")
        default:
            break
        }
        return url
    }
    
    mutating func setPurchaserInfo(_ info: Purchases.PurchaserInfo?) {
        guard let info = info else {
            return
        }
        
        let plusEntitlement = info.entitlements.all[SubscriptionTier.PLUS.rawValue]
        self.setPlusEntitlement(plusEntitlement)
    }
    
    mutating func setPlusEntitlement(_ entitlement: Purchases.EntitlementInfo?) {
        guard let entitlement = entitlement else {
            return
        }
        
        self.billingPlatform = BillingPlatform.fromStore(entitlement.store)
        self.willRenew = entitlement.willRenew
        self.isActive = entitlement.isActive
        self.periodType = entitlement.periodType
        self.firstPurchaseDate = entitlement.originalPurchaseDate
        self.latestPurchaseDate = entitlement.latestPurchaseDate
        self.expirationDate = entitlement.expirationDate
        self.unsubscribeDetectedDate = entitlement.unsubscribeDetectedAt
        self.billingIssueDetectedDate = entitlement.billingIssueDetectedAt
        self.skProductID = entitlement.productIdentifier
    }
    
    mutating func setSubscriptionDetails(_ details: SubscriptionDetails?) {
        guard let invoice = details?.upcomingInvoice else {
            return
        }
        if let card = invoice.defaultPaymentMethod?.card {
            self.ccLast4 = card.last4
            self.ccBrand = card.brand
        }
        
        if let amount = invoice.amountCentsUsd {
            self.nextAmountCentsUSD = amount
            self.nextAmount = formatPriceCents(amount)
        }
        
    }
    
    static func fromSubscriberData(_ data: SubscriberData, member: CactusMember?) -> SubscriptionDetailsViewModel {
        var model = SubscriptionDetailsViewModel(tier: member?.tier ?? .BASIC)
        model.trialDaysLeft = member?.subscription?.trialDaysLeft
        model.loaded = data.hasLoaded
        
        let details = data.subscriptionDetails
        let info = data.purchaserInfo
        model.setPurchaserInfo(info)
        model.setSubscriptionDetails(details)
        
        return model
    }
}

struct SubscriptionDetailsView: View {
    var model: SubscriptionDetailsViewModel
    
    var billingCycleMessage: String? {
        let expiration = FormatUtils.localizedDate(model.expirationDate, dateStyle: .short, timeStyle: .none)
        let expiresInFuture = model.expirationDate != nil ? model.expirationDate! > Date() : false
        let inTrial = model.periodType == .trial
        
        if expiresInFuture {
            if inTrial, model.willRenew, let expires = expiration {
                return "Your first bill is on \(expires)."
            } else if model.willRenew, let expires = expiration {
                return "Your subscription will renew on \(expires)."
            } else if inTrial, !model.willRenew, let expires = expiration {
                return "Your trial will end on \(expires). You will not be billed."
            } else if let expires = expiration {
                return "Your subscription will end on \(expires)."
            }
        } else if let expires = expiration {
            return "Your \(inTrial ? "trial" : "subscription") ended on \(expires)."
        }
        
        return nil
    }
    
    var body: some View {
        Group {
            if self.model.loaded {
                VStack(alignment: .leading, spacing: Spacing.normal) {
                    VStack(alignment: .leading) {
                        Text("Current Plan").font(CactusFont.bold(FontSize.normal).font).foregroundColor(NamedColor.TextDefault.color)
                        Text(self.model.tier.displayName).foregroundColor(NamedColor.TextDefault.color)
                    }
                    
                    if self.billingCycleMessage != nil {
                        Text(self.billingCycleMessage!).foregroundColor(NamedColor.TextDefault.color)
                    }
                    
                    if self.model.billingPlatform != nil {
                        PaymentInfoView(platform: self.model.billingPlatform!, manageUrl: self.model.manageSubscriptionUrl, cardBrand: self.model.ccBrand, last4: self.model.ccLast4)
                    }
                }.font(CactusFont.normal.font)
            } else {
                HStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    Text("Loading...")
                }.font(CactusFont.normal.font).foregroundColor(NamedColor.TextDefault.color)
            }
            
        }
    }
}

struct SubscriptionDetailsView_Previews: PreviewProvider {
    static let models: [SubscriptionDetailsViewModel] = [
        SubscriptionDetailsViewModel(tier: .PLUS, loaded: false, billingPlatform: .APPLE),
        SubscriptionDetailsViewModel(tier: SubscriptionTier.BASIC, billingPlatform: .STRIPE,
                                     ccLast4: "0212",
                                     ccBrand: .discover),
        SubscriptionDetailsViewModel(tier: .PLUS,
                                     billingPlatform: .STRIPE,
                                     ccLast4: "3323",
                                     ccBrand: .diners_club),
        SubscriptionDetailsViewModel(tier: .PLUS,
                                     billingPlatform: .APPLE,
                                     willRenew: true,
                                     periodType: .trial,
                                     expirationDate: Date.plus(days: 4)),
        SubscriptionDetailsViewModel(tier: .PLUS,
                                     billingPlatform: .APPLE,
                                     willRenew: false,
                                     periodType: .trial,
                                     expirationDate: Date.plus(days: 4)),
        
        SubscriptionDetailsViewModel(tier: .PLUS,
                                     billingPlatform: .APPLE,
                                     willRenew: false,
                                     expirationDate: Date.plus(days: 4)),
        SubscriptionDetailsViewModel(tier: .PLUS,
                                     billingPlatform: .APPLE,
                                     willRenew: false,
                                     expirationDate: Date.plus(days: -14)),
    ]
    
    static var previews: some View {
        
        Group {
            ForEach(ColorScheme.allCases, id: \.hashIdentifiable) { scheme in
                ForEach(models) { model in
                    SubscriptionDetailsView(model: model).previewDisplayName("\(model.loaded ? "" : "Loading -") \(model.billingPlatform?.rawValue.capitalized ?? "No Platform")\(model.periodType == .trial ? " - In Trial" : "") - \(model.willRenew ? "Renewing" : "Not Renewing") - \(model.tier.displayName) (\(String(describing: scheme)))".trimmingCharacters(in: .whitespaces))
                }
                    
                .padding()
                .background(NamedColor.Background.color)
                .colorScheme(scheme)
                .previewLayout(.sizeThatFits)
            }
            
        }
    }
}
