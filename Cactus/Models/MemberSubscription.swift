//
//  MemberSubscription.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

let DEFAULT_TRIAL_LENGTH_DAYS = 7

enum SubscriptionTier: String, Codable {
    case BASIC
    case PLUS
    case PREMIUM
    case UNKNOWN
    
    public init(from decoder: Decoder) throws {
        self = try SubscriptionTier(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
    
    var displayName: String {
        return getDisplayName(self)
    }
    
    static let PaidTiers: [SubscriptionTier] = [.PLUS, .PREMIUM]
    static let DisplaySortOrder: [SubscriptionTier] = [.UNKNOWN, .BASIC, .PLUS, .PREMIUM]
    
    var displaySortOrder: Int {
        return SubscriptionTier.DisplaySortOrder.firstIndex(of: self) ?? 0
    }
    
    var isPaidTier: Bool {
        return SubscriptionTier.PaidTiers.contains(self)
    }
}

class SubscriptionTrial: Codable {
    var startedAt: Date?
    var endsAt: Date?
    var activatedAt: Date?
    
    var isActivated: Bool {
        return self.activatedAt != nil 
    }
    
    ///A trial is ended when it is either activated or the end date has passed
    var trialEnded: Bool {
        guard let endsAt = self.endsAt else {
            return false
        }
        return self.isActivated || endsAt < Date()
    }
    
    ///get days left in trial. If it is activated, this will return `nil`
    var daysLeft: Int? {
        guard !self.isActivated, let end = self.endsAt, end > Date() else {
            return nil
        }
        guard let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: end).day else {
            return nil
        }
        return diffInDays
    }
    
//    static func getDefault(_ durationDays: Int=DEFAULT_TRIAL_LENGTH_DAYS) -> SubscriptionTrial {
//        let trial = SubscriptionTrial()
//        let startsAt = Date()
//        trial.startedAt = startsAt
//        trial.endsAt = Calendar.current.date(byAdding: .day, value: durationDays, to: startsAt)
//
//        return trial
//    }
}

class OptOutTrial: Codable {
    var billingPlatform: BillingPlatform?
    var endsAt: Date?
    var startedAt: Date?
}

class SubscriptionCancellation: Codable {
    var initiatedAt: Date?
    var accessEndsAt: Date?
    var reasonCode: String?
    var processedAt: Date?
}

class MemberSubscription: Codable {
    var trial: SubscriptionTrial?
    var tier: SubscriptionTier = .PLUS
    var legacyConversion: Bool? = false
    var optOutTrial: OptOutTrial?
    
    ///This field is protected because it should not be read directly from client code
    private var activated: Bool? = false
    var subscriptionProductId: String?
    var cancellation: SubscriptionCancellation?
    var stripeSubscriptionId: String?
    var appleOriginalTransactionId: String?
    var googlePurchaseToken: String?
    var googleOriginalOrderId: String?
    
    var trialDaysLeft: Int? {
        guard self.isInOptInTrial else {
            return nil
        }
        return trial?.daysLeft
    }
    
    var isOptOutTrial: Bool {
        guard self.tier.isPaidTier == true, let endsAt = self.optOutTrial?.endsAt else {
            return false
        }
        return endsAt > Date()
    }
    
    var isInOptInTrial: Bool {
        return self.tier.isPaidTier && !(self.trial?.trialEnded ?? true)
    }
    
    var isActivated: Bool {
        return self.tier.isPaidTier && !self.isInOptInTrial
    }
    
    var billingPlatform: BillingPlatform? {
        if self.appleOriginalTransactionId != nil {
            return .APPLE
        } else if self.googlePurchaseToken != nil || self.googleOriginalOrderId != nil {
            return .GOOGLE
        } else if self.stripeSubscriptionId != nil {
            return .STRIPE
        }
        return nil
    }
    
    var hasUpcomingCancellation: Bool {
        guard let accessEndsAt = self.cancellation?.accessEndsAt else {
            return false
        }
        
        return accessEndsAt > Date()
    }
    
    static func getDefault(trialDurationDays: Int = DEFAULT_TRIAL_LENGTH_DAYS) -> MemberSubscription {
        let subscription = MemberSubscription()
        subscription.tier = .BASIC
        subscription.activated = false
        subscription.legacyConversion = false
        //subscription.trial = SubscriptionTrial.getDefault(trialDurationDays)
        return subscription
    }
}
