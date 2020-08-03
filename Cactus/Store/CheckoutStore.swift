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
//    @Published var subscriptionProducts: [SubscriptionProduct] = []
//    @Published var productGroupEntryMap: SubscriptionProductGroupEntryMap?
    @Published var productGroupData: ProductGroupData = ProductGroupData()
    
    static var shared = CheckoutStore()
    
//    init(_ productGroupData: ProductGroupData?=nil) {
//        self.productGroupData = productGroupData ?? ProductGroupData()
//        CheckoutStore.shared = self
//    }
    
    func start() {
        productGroupData.start()
    }
    
    func stop() {
        self.productGroupData.stop()
    }
    
    deinit {
        self.stop()
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
