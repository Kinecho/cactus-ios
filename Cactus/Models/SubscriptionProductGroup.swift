//
//  SubscriptionProductGroup.swift
//  Cactus
//
//  Created by Neil Poulin on 2/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

struct ProductGroupFooter: Codable {
    var icon: String?
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

extension SubscriptionProductGroup {
    class Builder {
        private var entryId: String?
        private var title: String = "Mock Group"
        private var defaultPeriod: BillingPeriod = .monthly
        private var tier: SubscriptionTier = .PLUS
        private var description: String?
        private var footer: ProductGroupFooter?
        
        func setEntryId(_ id: String) -> Builder {
            self.entryId = id
            return self
        }
        
        func setTitle(_ name: String) -> Builder {
            self.title = name
            return self
        }
        
        func setDescriptionMarkdown(_ description: String) -> Builder {
            self.description = description
            return self
        }
       
        func setTier(_ tier: SubscriptionTier) -> Builder {
            self.tier = tier
            return self
        }
        
        func setDefaultSelectedPeriod(_ period: BillingPeriod) -> Builder {
            self.defaultPeriod = period
            return self
        }
        
        func setFooter(text: String?, icon: String? ) -> Builder {
            let footer = ProductGroupFooter(icon: icon, textMarkdown: text)
            self.footer = footer
            return self
        }
        
        func build() -> SubscriptionProductGroup {
            let group = SubscriptionProductGroup()
            group.entryId = self.entryId
            group.documentId = self.entryId
            group.defaultSelectedPeriod = self.defaultPeriod
            group.title = self.title
            group.subscriptionTier = self.tier
            group.descriptionMarkdown = self.description
            group.footer = self.footer
            return group
        }
    }
}
