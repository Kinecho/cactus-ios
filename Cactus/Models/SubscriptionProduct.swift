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
    
    static let reoccurringPeriods: [BillingPeriod] = [.weekly, .monthly, .yearly]
    
    var isReoccurring: Bool {
        return BillingPeriod.reoccurringPeriods.contains(self)
    }
    
    var displayName: String? {
        switch self {
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
        switch self {
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

class SubscriptionProduct: FlamelinkIdentifiable, Identifiable {
    static var Fields = SubscriptionProductField.self
    static var schema = FlamelinkSchema.subscriptionProducts
    var _fl_meta_: FlamelinkMeta?
    var order: Int?
    var documentId: String?
    var entryId: String?
    
    var id: String {
        self.entryId ?? UUID().uuidString
    }
    
    var displayName: String
    var priceCentsUsd: Int
    var subscriptionTier: SubscriptionTier = SubscriptionTier.UNKNOWN
    var billingPeriod: BillingPeriod
    var appleProductId: String?
    var availableForSale: Bool = false
    var savingsCopy: String?
    var stripePlanId: String?
    
    init(displayName: String, priceCents: Int, billingPeriod: BillingPeriod) {
        self.displayName = displayName
        self.priceCentsUsd = priceCents
        self.billingPeriod = billingPeriod
    }
    
    var isFree: Bool {
        return self.billingPeriod == .never || self.priceCentsUsd == 0
    }
}

extension SubscriptionProduct {
    class Builder {
        private var entryId: String?
        private var displayName: String = "Mock Product - Default Name"
        private var priceCentsUsd: Int = 999
        private var billingPeriod: BillingPeriod = .monthly
        
        func setEntryId(_ id: String) -> Builder {
            self.entryId = id
            return self
        }
        
        func setDisplayName(_ name: String) -> Builder {
            self.displayName = name
            return self
        }
        
        func setPrice(centsUsd: Int) -> Builder {
            self.priceCentsUsd = centsUsd
            return self
        }
        
        func setBillingPeriod(_ period: BillingPeriod) -> Builder {
            self.billingPeriod = period
            return self
        }
        
        func build() -> SubscriptionProduct {
            let subProduct = SubscriptionProduct(displayName: self.displayName, priceCents: self.priceCentsUsd, billingPeriod: self.billingPeriod)
            subProduct.entryId = self.entryId
            
            
            return subProduct
        }
    }
}
