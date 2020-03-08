//
//  ApplePayment.swift
//  Cactus
//
//  Created by Neil Poulin on 3/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit
struct VerifyReceiptParams: Codable {
    ///Base64 encoded receipt data
    var receiptData: String
    
    init(receiptData: String) {
        self.receiptData = receiptData
    }
}

struct VerifyReceiptResult: Codable {
    var success: Bool
    var message: String?
    var error: String?
//    var receipt: Receipt
}
