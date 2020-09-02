//
//  StoreKit+Cactus.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit

extension SKProductSubscriptionPeriod {
    var billingPeriod: BillingPeriod {
        switch self.unit {
        case .day:
            return BillingPeriod.unknown
        case .week:
            return BillingPeriod.weekly
        case .month:
            return BillingPeriod.monthly
        case .year:
            return BillingPeriod.yearly
        default:
            return BillingPeriod.unknown
        }
    }
}
