//
//  SubscriptionProductService.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class SubscriptionProductService {
    static var sharedInstance = SubscriptionProductService()
    let flamelinkService: FlamelinkService
    let logger = Logger("SubscriptionProductService")
    let schema = FlamelinkSchema.subscriptionProducts
    
    private init() {
        self.flamelinkService = FlamelinkService.sharedInstance
    }
    
    func getBaseQuery() -> Query {
        return self.flamelinkService.getQuery(self.schema)
    }
    
    func getByEntryId(id: String, _ onData: @escaping (SubscriptionProduct?, Any?) -> Void) {
        flamelinkService.getByEntryId(id, schema: self.schema) { (subscriptionProduct: SubscriptionProduct?, error) in
            self.logger.debug("Fetched subscriptionProduct for entryId \(id)")
            if let error = error {
                self.logger.error("Failed to fetch subscriptionProduct", error)
            }
            onData(subscriptionProduct, error)
        }
    }
    
    func getAllForSale(_ completed: @escaping (FlamelinkQueryResult<SubscriptionProduct>) -> Void) {
        let query = self.getBaseQuery().whereField(SubscriptionProduct.Fields.availableForSale, isEqualTo: true)
        self.flamelinkService.executeQuery(query) { (results, error) in
            completed(FlamelinkQueryResult(results, error))
        }
    }
}
