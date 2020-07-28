//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

final class CheckoutStore: ObservableObject {
    var subscriptionProducts: [SubscriptionProduct] = []
    
    var productGroupEntryMap: SubscriptionProductGroupEntryMap?
    
    var productsListener: ListenerRegistration?
    
    func start() {
        self.productsListener = SubscriptionService.sharedInstance.getSubscriptionProductGroupEntryMap { (entryMap) in
            self.productGroupEntryMap = entryMap
        }
    }
    
}
