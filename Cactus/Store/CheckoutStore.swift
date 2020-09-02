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
import StoreKit
import FirebaseFirestore

final class CheckoutStore: ObservableObject, StoreObserverDelegate {
    
    @Published var productGroupData: ProductGroupData = ProductGroupData()
    @Published var checkoutInProgress: Bool = false
    @Published var checkoutResult: CompletePurchaseResult?
    
    static var shared = CheckoutStore()
    
    init() {
        StoreObserver.sharedInstance.delegate = self
    }
    
    func start() {
        productGroupData.start()        
    }
    
    func stop() {
        self.productGroupData.stop()
    }
    
    deinit {
        self.stop()
    }
    
    func submitPurchase(_ product: SKProduct) {
        self.checkoutInProgress = true
        SubscriptionService.sharedInstance.submitPurchase(product: product)
    }
    
    func restorePurchases() {
        self.checkoutInProgress = true
        StoreObserver.sharedInstance.restore()
    }
    
    func handlePurchseCompleted(verifyReceiptResult: CompletePurchaseResult?, error: Any?) {
        DispatchQueue.main.async {
            self.checkoutInProgress = false
            self.checkoutResult = verifyReceiptResult
            if let error = error {
                Logger.shared.error("Failed to checkout", error)
            }
        }        
    }
    
}

extension CheckoutStore {
    static func mock(loading: Bool=false) -> CheckoutStore {
        let productGroupData = ProductGroupData.mock(loading: loading)
        let store = CheckoutStore()
        store.productGroupData = productGroupData
        return store
    }
}
