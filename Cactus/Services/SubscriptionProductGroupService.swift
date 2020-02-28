//
//  SubscriptionProductGroupService.swift
//  Cactus
//
//  Created by Neil Poulin on 2/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class SubscriptionProductGroupService {
    static var sharedInstance = SubscriptionProductGroupService()
    let flamelinkService: FlamelinkService
    var logger = Logger("SubscriptionProductGroupService")
    let schema = FlamelinkSchema.subscriptionProductGroups
    
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
    
    func getAll(_ completed: @escaping (FlamelinkQueryResult<SubscriptionProductGroup>) -> Void) {
        let query = self.getBaseQuery()
        self.flamelinkService.executeQuery(query) { (results, error) in
            completed(FlamelinkQueryResult(results, error))
        }
    }
}
