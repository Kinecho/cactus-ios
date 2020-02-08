//
//  SubscriptionProduct.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

enum BillingPeriod: String, Codable {
    case monthly
    case yearly
    case unknown
    
    public init (from decoder: Decoder) throws {
        self = try BillingPeriod(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

class SubscriptionProduct: FlamelinkIdentifiable {
    
    static var schema = FlamelinkSchema.subscriptionProducts
    var _fl_meta_: FlamelinkMeta?
    var order: Int?
    var documentId: String?
    var entryId: String?
    
    var displayName: String
    var priceCentsUsd: Int
    var billingPeriod: BillingPeriod
    var appleProductId: String?
}
