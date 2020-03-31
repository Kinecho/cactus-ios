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
    init(receiptData: String, restored: Bool) {
        self.receiptData = receiptData
        self.restored = restored
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
