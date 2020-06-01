//
//  ApplePayment.swift
//  Cactus
//
//  Created by Neil Poulin on 3/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit

struct CompletePurchaseRequest: Codable {
    ///Base64 encoded receipt data
    var receiptData: String
    var restored: Bool
    var localePriceFormatted: String?
    var price: Decimal?
    var priceLocale: String?
    
    init(receiptData: String, restored: Bool, product: SKProduct?) {
        self.receiptData = receiptData
        self.restored = restored
        self.localePriceFormatted = formatApplePrice(product?.price, locale: product?.priceLocale)
        self.priceLocale = product?.priceLocale.identifier
        self.price = product?.price.decimalValue
    }
}

struct FulfillmentResult: Codable {
    var success: Bool = false
    var message: String?
}

struct CompletePurchaseResult: Codable {
    var success: Bool = false
    var message: String?
    var error: String?
    var fulfillmentResult: FulfillmentResult?
//    var receipt: Receipt
}
