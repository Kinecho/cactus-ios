//
//  SubscriptionUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit
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

struct ProductEntry {
    var subscriptionProduct: SubscriptionProduct
    var appleProduct: SKProduct?
    
    init(subscriptionProduct: SubscriptionProduct, appleProduct: SKProduct?) {
        self.subscriptionProduct = subscriptionProduct
        self.appleProduct = appleProduct
    }
}

struct SubscriptionProductGroupEntry {
    var tier: SubscriptionTier
    var products: [ProductEntry]
    var appleProducts: [SKProduct]?
    var productGroup: SubscriptionProductGroup?
    var defaultSelectedPeriod: BillingPeriod? {
        return self.productGroup?.defaultSelectedPeriod
    }
    
    init (group: SubscriptionProductGroup, products: [SubscriptionProduct]=[], appleProducts: [SKProduct]=[]) {
        self.tier = group.subscriptionTier
        self.products = products.compactMap({ (p) -> ProductEntry? in
            let appleProduct: SKProduct? = appleProducts.first { (sp) -> Bool in
                return sp.productIdentifier == p.appleProductId
            }
            guard appleProduct != nil else {
                return nil
            }
            return ProductEntry(subscriptionProduct: p, appleProduct: appleProduct)
        })
        self.productGroup = group
    }
}

typealias SubscriptionProductGroupEntryMap = [SubscriptionTier: SubscriptionProductGroupEntry]

func createSubscriptionProductGroupEntryMap(products: [SubscriptionProduct]?, groups: [SubscriptionProductGroup]?, appleProducts: [SKProduct]?=nil) -> SubscriptionProductGroupEntryMap? {
    guard var products = products, let groups = groups else {
        return nil
    }
        
    return groups.reduce([:]) { (map, group) -> SubscriptionProductGroupEntryMap in
        var map = map
        guard let tier = group.subscriptionTier else {
            return map
        }
        let productsForTier = products.filter {$0.subscriptionTier == tier}
        products.sort { (p1, p2) -> Bool in
            return  p2.billingPeriod.displaySortOrder > p1.billingPeriod.displaySortOrder
        }
        let entry = SubscriptionProductGroupEntry(group: group, products: productsForTier, appleProducts: appleProducts ?? [])
        map[tier] = entry
        return map
    }
}
