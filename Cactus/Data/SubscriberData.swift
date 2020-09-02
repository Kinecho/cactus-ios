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

enum SubscriberDataError: Error {
    case noMember
}

class SubscriberData: ObservableObject {
    var hasLoaded: Bool {
        purchaserInfoLoaded && detailsLoaded
    }
    @Published var error: Error?
    @Published var subscriptionDetails: SubscriptionDetails?
    @Published var detailsLoaded = false
    @Published var purchaserInfo: Purchases.PurchaserInfo?
    @Published var purchaserInfoLoaded = false
    
    let logger = Logger("SubscriberData")
    
    init(autoFetch: Bool=true) {
        if autoFetch {
            self.fetch()
        }
    }
    
    func fetch() {
        DispatchQueue.main.async {
            self.detailsLoaded = false
            self.purchaserInfoLoaded = false
            self.error = nil
            
            
            ApiService.sharedInstance.getSubscriptionDetails { (details, error) in
                if let error = error {
                    self.logger.error("Failed to get revenuecat purchaser info", error)
                }
                DispatchQueue.main.async {
                    self.subscriptionDetails = details
                    self.detailsLoaded = true
                }
                
            }
            Purchases.shared.purchaserInfo { (info, error) in
                if let error = error {
                    self.logger.error("Failed to get revenuecat purchaser info", error)
                }
                DispatchQueue.main.async {
                    self.purchaserInfo = info
                    self.error = error
                    self.purchaserInfoLoaded = true
                }
            }
        }
    }
}


extension SubscriberData {
    static func mock() -> SubscriberData {
        let data = SubscriberData(autoFetch: false)
        
        return data
    }
    
    
    class Builder {
        var revenueCatLoaded = true
        var detailsLoaded = true
        
        var details: SubscriptionDetails?
        var info: Purchases.PurchaserInfo?
        
        func setPurchaserLoaded(_ loaded: Bool=true) -> Builder {
            self.revenueCatLoaded = loaded
            return self
        }
        
        func setDetailsLoaded(_ loaded: Bool=true) -> Builder {
            self.detailsLoaded = loaded
            return self
        }
        
        func setPurchaserInfo(_ info: Purchases.PurchaserInfo?) -> Builder {
            self.info = info
            return self
        }
        
        func setDetails(_ details: SubscriptionDetails?) -> Builder {
            self.details = details
            return self
        }
        
        func build() -> SubscriberData {
            let data = SubscriberData(autoFetch: false)
            data.detailsLoaded = self.detailsLoaded
            data.purchaserInfoLoaded = self.revenueCatLoaded
            data.subscriptionDetails = self.details
            data.purchaserInfo = self.info
            return data
        }
        
    }
}
