//
//  AppSettings.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class AppSettings: FlamelinkIdentifiable {
    static var schema = FlamelinkSchema.appSettings_ios
    var _fl_meta_: FlamelinkMeta?
    var documentId: String?
    var entryId: String?
    var order: Int?
    var firstPromptContentEntryId: String?
    var checkoutSettings: CheckoutSettings?
    var insights: InsightsSettings?
    var welcome: WelcomeSettings?
    var pricingScreen: PricingScreenSettings?
    var apiDomain: String?
    var upgradeCopy: UpgradeCopy?
}

struct PricingFeature: Codable {
    var icon: IconType?
    var titleMarkdown: String?
    var descriptionMarkdown: String?
    
    static func create(icon: IconType?, title: String?, description: String?) -> PricingFeature {
        var f = PricingFeature()
        f.icon = icon
        f.titleMarkdown = title
        f.descriptionMarkdown = description
        return f
    }
}

let DEFAULT_PRICING_FEATURES: [PricingFeature] = [
    PricingFeature.create(icon: .calendar, title: "Make it daily", description: "Improve your focus and positivity at work and home with a fresh prompt, every day."),
    PricingFeature.create(icon: .pie, title: "Personalized insights", description: "Visualizations reveal the people, places, and things that contribute to your satisfaction."),
    PricingFeature.create(icon: .journal, title: "Look back", description: "As your journal fills up, celebrate and relive the positive forces in your life."),
    PricingFeature.create(icon: .lock, title: "Private + secure", description: "Your journal entries are encrypted for your eyes only."),
]

class PricingScreenSettings: Codable {
    var pageTitleMarkdown: String?
    var pageDescriptionMarkdown: String?
    var purchaseButtonText: String?
    var features: [PricingFeature]?
    var headerBackgroundHeight: CGFloat? = 260        
}

class WelcomeSettings: Codable {
    var taglineMarkdown: String?
}

class InsightsSettings: Codable {
    var insightsTitle: String?
    var insightsDescription: String?
    var noTextTodayTitle: String?
    var noTextTodayMessage: String?
    var revealInsightMessage: String?
    var revealInsightButtonText: String?
    var revealInsightUpgradeMessage: String?
    var learnMoreButtonText: String?
    var celebrateInsightsEnabled: Bool? = false
}

class JournalHomeUpgradeBannerCopy: Codable {
    var title: String = ""
    var descriptionMarkdown: String = ""
    var upgradeButtonText: String = ""    
}

class JournalHomeUpgradeCopyGroups: Codable {
    var basicTier: JournalHomeUpgradeBannerCopy
}

class ManageSubscriptionCopy: Codable {
    var upgradeFromOptInTrian: String = ""
    var upgradeFromBasicMarkdown: String = ""
    var upgradeButtonText: String? = "Try Cactus Plus"
}

class CelebrateUpgradeCopy: Codable {
    var upgradeBasicDescriptionMarkdown: String? = "Get daily insights and more"
}

class UpgradeCopy: Codable {
    var journalHomeBanner: JournalHomeUpgradeCopyGroups
    var manageSubscription: ManageSubscriptionCopy
    var celebrate: CelebrateUpgradeCopy
}

class CheckoutSettings: Codable {
    var pricingPath: String?
    var learnMorePath: String?
    var upgradePath: String?
    var inAppPaymentsEnabled: Bool = false
    
    enum CheckoutSettingsCodingKey: CodingKey {
        case pricingPath
        case learnMorePath
        case upgradePath
        case inAppPaymentsEnabled
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
            self.inAppPaymentsEnabled = (try? container.decode(Bool.self, forKey: .inAppPaymentsEnabled)) ?? false
        } catch {
            Logger.shared.error("Failed to decode checkout settings", error)
        }
    }
}
