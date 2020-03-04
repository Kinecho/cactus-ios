//
//  SubscriptionProductGroup.swift
//  Cactus
//
//  Created by Neil Poulin on 2/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

struct ProductGroupFooter: Codable {
    var icon: IconType?
    var textMarkdown: String?
}

class SubscriptionProductGroup: FlamelinkIdentifiable {
    static var Fields = SubscriptionProductField.self
    static var schema = FlamelinkSchema.subscriptionProducts
    var _fl_meta_: FlamelinkMeta?
    var order: Int?
    var documentId: String?
    var entryId: String?
    
    var subscriptionTier: SubscriptionTier!
    var title: String?
    var descriptionMarkdown: String?
    var defaultSelectedPeriod: BillingPeriod?
//    var sections: ProductSection[] = []; //not supported yet
    var trialUpgradeMarkdown: String?
    var footer: ProductGroupFooter?
    
}
