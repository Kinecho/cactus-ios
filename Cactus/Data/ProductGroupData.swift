//
//  ProductGroupData.swift
//  Cactus
//
//  Created by Neil Poulin on 8/1/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore
import StoreKit
import Purchases

class ProductGroupData {
    let logger = Logger("ProductGroupData")
    var subscriptionProducts: [SubscriptionProduct]?
    var subscriptionProductsLoaded = false
    var subscriptionProductsListener: ListenerRegistration?
    
    var productGroups: [SubscriptionProductGroup]?
    var productGroupsLoaded = false
    var productGroupsListener: ListenerRegistration?
    
    var appleRequests: [ProductRequest] = []
    var appleProducts: [SKProduct]?
    var appleProductsLoaded = false
    
    var rcPackages: [Purchases.Package]?
    var rcPackagesLoaded = false
    
    var appleProductIds: [String]? {
        guard let products = self.subscriptionProducts else {
            return nil
        }
        return products.compactMap({ isBlank($0.appleProductId) ? nil : $0.appleProductId })
    }
    
    var allLoaded: Bool {
        return self.subscriptionProductsLoaded && self.productGroupsLoaded && self.appleProductsLoaded && self.rcPackagesLoaded
    }
    
    var subscriptionProductGroupEntryMap: SubscriptionProductGroupEntryMap? {
        guard self.allLoaded else {
            return nil
        }
        return createSubscriptionProductGroupEntryMap(products: subscriptionProducts, groups: productGroups, appleProducts: appleProducts)        
    }
    
    func start() {
        self.fetchRevenueCatOfferings()
        
        self.productGroupsListener = SubscriptionProductGroupService.sharedInstance.observeAll { (groupResult) in
            defer {
                self.subscriptionProductsLoaded = true
            }
            if let error = groupResult.error {
                self.logger.error("Failed to get product groups from flamelink", error)
                return
            }
            self.productGroups = groupResult.results
        }
        
        self.subscriptionProductsListener = SubscriptionProductService.sharedInstance.observeAllForSale { (productResult) in
            defer {
                self.subscriptionProductsLoaded = true
            }
            if let error = productResult.error {
                self.logger.error("Failed to get products flamelink", error)
                return
            }
            let products = productResult.results
            self.subscriptionProducts = products
        }
    }
    
    func fetchRevenueCatOfferings() {
        Purchases.shared.offerings { (offerings, error) in            
            if let error = error {
                self.logger.error("Error fetching revenuecat offerings", error)
            }
            
            if let packages = offerings?.current?.availablePackages {
                self.rcPackages = packages
                self.rcPackagesLoaded = true
            }
        }
    }
    
    func fetchAppleProducts() {
        guard let appleIds = self.appleProductIds else {
            return
        }
        
        let appleRequest = ProductRequest()
        self.appleRequests.append(appleRequest)
        appleRequest.fetchAppleProducts(appleProductIds: appleIds, completed: {
            self.appleProducts = appleRequest.availableAppleProducts
            self.appleProductsLoaded = true
            self.appleRequests.removeAll {$0 == appleRequest}
        })
    }
    
    func stop() {
        self.productGroupsListener?.remove()
        self.subscriptionProductsListener?.remove()
    }
}

extension ProductGroupData {
    static func mock(loading: Bool=false) -> ProductGroupData {
        let data = ProductGroupData()
        
        data.rcPackagesLoaded = !loading
        data.appleProductsLoaded = !loading
        data.subscriptionProductsLoaded = !loading
        data.productGroupsLoaded = !loading
        
        if !loading {            
            data.subscriptionProducts = [
                SubscriptionProduct.Builder()
                    .setEntryId("monthly1")
                    .setDisplayName("Mock - Monthly")
                    .setPrice(centsUsd: 999)
                    .setBillingPeriod(.monthly)
                    .build(),
                SubscriptionProduct.Builder()
                    .setEntryId("annual1")
                    .setDisplayName("Mock - Yearly")
                    .setPrice(centsUsd: 4999)
                    .setBillingPeriod(.yearly)
                    .build()
            ]
            
            data.productGroups = [
                SubscriptionProductGroup.Builder()
                    .setEntryId("group1")
                    .setTier(.BASIC)
                    .setTitle("Group - Basic")
                    .setDescriptionMarkdown("This is a **basic** group.")
                    .setDefaultSelectedPeriod(.monthly)
                    .setFooter(text: "This is a custom footer", icon: "activity")
                    .build(),
                SubscriptionProductGroup.Builder()
                    .setEntryId("group2")
                    .setTier(.PLUS)
                    .setTitle("Group - PLUS")
                    .setDescriptionMarkdown("This is a **PLUS** group.")
                    .setDefaultSelectedPeriod(.monthly)
                    .setFooter(text: "Get it now!", icon: "gift")
                    .build()
            ]            
        }
        
        return data
    }
}
