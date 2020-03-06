//
//  AppSettings.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation


class AppSettings: FlamelinkIdentifiable {
    static var schema = FlamelinkSchema.appSettings_ios
    var _fl_meta_: FlamelinkMeta?
    var documentId: String?
    var entryId: String?
    var order: Int?
    var firstPromptContentEntryId: String?
    var checkoutSettings: CheckoutSettings?
    var insights: InsightsSettings?
}

class InsightsSettings: Codable {
    var noTextTodayTitle: String?
    var noTextTodayMessage: String?
    var celebrateInsightsEnabled: Bool = false
}

class CheckoutSettings: Codable {
    var pricingPath: String?
    var learnMorePath: String?
    var upgradePath: String?
    var useWebForCheckout: Bool = false
    
    enum CheckoutSettingsCodingKey: CodingKey {
        case pricingPath
        case learnMorePath
        case upgradePath
        case useWebForCheckout
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CheckoutSettingsCodingKey.self)
            
            if let learnMorePath = try? container.decode(String.self, forKey: .learnMorePath), !isBlank(learnMorePath) {
                self.learnMorePath = learnMorePath
            }
            
            if let upgradePath = try? container.decode(String.self, forKey: .upgradePath), !isBlank(upgradePath) {
                self.upgradePath = upgradePath
            }
                        
            if let pricingPath = try? container.decode(String.self, forKey: .pricingPath), !isBlank(pricingPath) {
                self.pricingPath = pricingPath
            }
            self.useWebForCheckout = (try? container.decode(Bool.self, forKey: .useWebForCheckout)) ?? false
        } catch {
            Logger.shared.error("Failed to decode checkout settings", error)
        }
    }
}
