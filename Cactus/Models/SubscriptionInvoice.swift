//
//  SubscriptionInvoice.swift
//  Cactus
//
//  Created by Neil Poulin on 3/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Purchases

enum WalletType: String, Codable {
    case amex_express_checkout
    case apple_pay
    case google_pay
    case masterpass
    case samsung_pay
    case visa_checkout
}

enum CardBrand: String, Codable {
    case unknown
    case american_express
    case mastercard
    case diners_club
    case discover
    case jcb
    case union_pay
    case visa
    
    public init(from decoder: Decoder) throws {
        self = try CardBrand(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    var displayName: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .american_express:
            return "American Express"
        case .mastercard:
            return "MasterCard"
        case .diners_club:
            return "Diners Club"
        case .discover:
            return "Discover"
        case .jcb:
            return "JCB"
        case .union_pay:
            return "UnionPay"
        case .visa:
            return "Visa"        
        }
    }
}

class CardPaymentMethod: Codable {
    var brand: CardBrand?
    var country: String?
    var last4: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var cardholderName: String?
    var walletType: WalletType?
}

enum InvoiceStatus: String, Codable {
    case draft
    case open
    case paid
    case uncollectible
    case void
    case deleted
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try InvoiceStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum SubscriptionStatus: String, Codable {
    case pending
    case in_trial
    case active
    case expired
    case canceled
    case unknown
    case past_due
    
    static let endedStatuses: [SubscriptionStatus] = [.expired, .canceled, .past_due]
    static let activeStatuses: [SubscriptionStatus] = [.in_trial, .active]
    
    var isActive: Bool {
        SubscriptionStatus.activeStatuses.contains(self)
    }
    
    var isEnded: Bool {
        SubscriptionStatus.endedStatuses.contains(self)
    }
    
    public init(from decoder: Decoder) throws {
        self = try SubscriptionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum BillingPlatform: String, Codable {
    case STRIPE
    case APPLE
    case GOOGLE
    case PROMOTIONAL
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try BillingPlatform(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    var displayName: String {
        switch self {
        case .STRIPE:
            return "Stripe"
        case .APPLE:
            return "App Store"
        case .GOOGLE:
            return "Play Store"
        case .PROMOTIONAL:
            return "Promotional"
        default:
            return ""
        }
    }
    
    var cactusImage: CactusImage? {
        switch self {
        case .APPLE:
            return CactusImage.apple
        case .GOOGLE:
            return CactusImage.google
        case .STRIPE:
            return CactusImage.creditCard
        default:
            return nil
        }
    }
    
    static func fromStore(_ store: Purchases.Store) -> BillingPlatform {
        switch store {
        case .macAppStore:
            return .APPLE
        case .appStore:
            return .APPLE
        case .playStore:
            return .GOOGLE
        case .promotional:
            return .PROMOTIONAL
        case .stripe:
            return .STRIPE
        case .unknownStore:
            return .unknown
        default:
            return .unknown
        }
    }
}

class PaymentMethod: Codable {
    var card: CardPaymentMethod
    var isDefault: Bool?
}

class AppleProductPrice: Codable {
    var localePriceFormatted: String?
    var price: Decimal?
    var priceLocale: String?    
}

class SubscriptionInvoice: Codable {
    var defaultPaymentMethod: PaymentMethod?
    var amountCentsUsd: Int?
    var periodStart_epoch_seconds: Int?
    var periodEnd_epoch_seconds: Int?
    var nextPaymentDate_epoch_seconds: Int?
    var paid: Bool?
    var status: InvoiceStatus?
    var stripeInvoiceId: String?
    var stripeSubscriptionId: String?
    var isAppleSubscription: Bool?
    var billingPlatform: BillingPlatform
    var appleProductId: String?
    var isAutoRenew: Bool?
    var androidProductId: String?
    var androidPackageName: String?
    var isExpired: Bool?
    var subscriptionStatus: SubscriptionStatus
    var optOutTrialStartsAt_epoch_seconds: Int?
    var optOutTrialEndsAt_epoch_seconds: Int?
    var appleProductPrice: AppleProductPrice?
    // MARK: computed properties
    var isInOptOutTrial: Bool {
        return self.subscriptionStatus == .in_trial
    }
    
    var optOutTrialEndsAt: Date? {
        return optDateFromSeconds(self.optOutTrialEndsAt_epoch_seconds)
    }
    
    var optOutTrialStartsAt: Date? {
        return optDateFromSeconds(self.optOutTrialStartsAt_epoch_seconds)
    }
    
    var periodEndAt: Date? {
        return optDateFromSeconds(self.periodEnd_epoch_seconds)
    }
    
    var periodStartAt: Date? {
        return optDateFromSeconds(self.periodStart_epoch_seconds)
    }
    
}

class SubscriptionDetails: Codable {
    var upcomingInvoice: SubscriptionInvoice?
    var subscriptionProduct: SubscriptionProduct?
}
