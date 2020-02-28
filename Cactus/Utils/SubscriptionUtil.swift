//
//  SubscriptionUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

func getDisplayName(_ tier: SubscriptionTier) -> String {
    switch tier {
    case .PLUS:
        return "Plus"
    case .BASIC:
        return "Basic"
    case .PREMIUM:
        return "Premium"
    default:
        return ""
    }
}

struct SubscriptionProductGroupEntry {
    var tier: SubscriptionTier
    var products: [SubscriptionProduct]
    var productGroup: SubscriptionProductGroup?
    var defaultSelectedPeriod: BillingPeriod? {
        return self.productGroup?.defaultSelectedPeriod
    }
    
    init (group: SubscriptionProductGroup, products: [SubscriptionProduct]=[]) {
        self.tier = group.subscriptionTier
        self.products = products
        self.productGroup = group
    }
}

typealias SubscriptionProductGroupEntryMap = [SubscriptionTier: SubscriptionProductGroupEntry]

func createSubscriptionProductGroupEntryMap(products: [SubscriptionProduct]?, groups: [SubscriptionProductGroup]?) -> SubscriptionProductGroupEntryMap? {
    guard let products = products, let groups = groups else {
        return nil
    }
        
    return groups.reduce([:]) { (map, group) -> SubscriptionProductGroupEntryMap in
        var map = map;
        guard let tier = group.subscriptionTier else {
            return map
        }
        let productsForTier = products.filter {$0.subscriptionTier == tier}
        let entry = SubscriptionProductGroupEntry(group: group, products: productsForTier)
        map[tier] = entry
        return map
    }
}
