//
//  SubscriptionInvoice.swift
//  Cactus
//
//  Created by Neil Poulin on 3/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

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

class PaymentMethod: Codable {
    var card: CardPaymentMethod
    var isDefault: Bool?
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
    var isAutoRenew: Bool?
}

class SubscriptionDetails: Codable {
    var upcomingInvoice: SubscriptionInvoice?
    var subscriptionProduct: SubscriptionProduct?
}
