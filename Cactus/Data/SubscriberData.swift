//
//  SubscriberData.swift
//  Cactus
//
//  Created by Neil Poulin on 8/6/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import SwiftUI
import Purchases
class SubscriberData: ObservableObject {
    var hasLoaded: Bool {
        purchaserInfoLoaded && detailsLoaded
    }
    @Published var error: Error?
    @Published var subscriptionDetails: SubscriptionDetails?
    @Published var detailsLoaded = false
    @Published var purchaserInfo: RevenueCat.PurchaserInfo?
    @Published var purchaserInfoLoaded = false
    
    var member: CactusMember?
    
    let logger = Logger("SubscriberData")
    
    init() {
        self.fetch(nil)
    }
    
    func fakeFetch() {
        self.detailsLoaded = false
        self.purchaserInfoLoaded = false
    }
    
    func fetch(_ member: CactusMember?=nil) {
        self.detailsLoaded = false
        self.purchaserInfoLoaded = false
//        self.member = member
        SubscriptionService.sharedInstance.getSubscriptionDetails { (details, error) in
            if let error = error {
                self.logger.error("Failed to get revenuecat purchaser info", error)
            }
            self.subscriptionDetails = details
            self.detailsLoaded = true
        }
        RevenueCat.shared.invalidatePurchaserInfoCache()
        RevenueCat.shared.purchaserInfo { (info, error) in
            if let error = error {
                self.logger.error("Failed to get revenuecat purchaser info", error)
            }
            self.purchaserInfo = info
            self.error = error
            self.purchaserInfoLoaded = true
        }
    }
    
    
}
