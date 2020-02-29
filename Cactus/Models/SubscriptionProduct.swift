//
//  SubscriptionProduct.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

enum BillingPeriod: String, Codable {
    case never
    case once
    case weekly
    case monthly
    case yearly
    case unknown
    
    public init (from decoder: Decoder) throws {
        self = try BillingPeriod(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    static let displaySortOrder: [BillingPeriod] = [BillingPeriod.never, BillingPeriod.once, BillingPeriod.weekly, BillingPeriod.monthly, BillingPeriod.yearly]
    
    var displaySortOrder: Int {
        return BillingPeriod.displaySortOrder.firstIndex(of: self) ?? 0
    }
    
    var displayName: String? {
        switch(self) {
        case .never:
            return nil
        case .once:
            return "once"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        case .yearly:
            return "year"
        case .unknown:
            return nil
        }
    }
    
    var productTitle: String? {
        switch(self) {
        case .never:
            return "Free"
        case .once:
            return "One Time"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Annual"
        case .unknown:
            return nil             
        }
    }
}

class SubscriptionProductField {
    public static let availableForSale = "availableForSale"
}

class SubscriptionProduct: FlamelinkIdentifiable {
    static var Fields = SubscriptionProductField.self
    static var schema = FlamelinkSchema.subscriptionProducts
    var _fl_meta_: FlamelinkMeta?
    var order: Int?
    var documentId: String?
    var entryId: String?
    
    var displayName: String
    var priceCentsUsd: Int
    var subscriptionTier: SubscriptionTier = SubscriptionTier.UNKNOWN
    var billingPeriod: BillingPeriod
    var appleProductId: String?
    var availableForSale: Bool = false
    var savingsCopy: String?
    var stripePlanId: String?
    
    var isFree: Bool {
        return self.billingPeriod == .never || self.priceCentsUsd == 0
    }
}
