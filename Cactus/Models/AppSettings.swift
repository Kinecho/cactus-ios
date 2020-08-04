//
//  AppSettings.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import NoveFeatherIcons
fileprivate let logger = Logger("AppSettings")

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
    var coreValuesPath: String? = "/core-values/embed"
    var upgradeCopy: UpgradeCopy?
    var dataExport: DataExportSettings?
    var journal: JournalSettings?
    
    enum AppSettingsField: CodingKey {
        case _fl_meta_
        case documentId
        case entryId
        case order
        case firstPromptContentEntryId
        case checkoutSettings
        case insights
        case welcome
        case pricingScreen
        case apiDomain
        case upgradeCopy
        case dataExport
        case journal
        case coreValuesPath
    }
    
    init() {
        logger.info("Using no arg consturctor to create settings object")
    }
    
    public required init(from decoder: Decoder) throws {
        let model = try ModelDecoder<AppSettingsField>.create(decoder: decoder, codingKeys: AppSettingsField.self) 
        self._fl_meta_ = try? model.container.decode(FlamelinkMeta.self, forKey: ._fl_meta_)
        self.documentId = model.optionalString(.documentId, blankAsNil: true)
        self.entryId = model.optionalString(.entryId, blankAsNil: true)
        self.order = model.optionalInt(.order)
        self.firstPromptContentEntryId = model.optionalString(.firstPromptContentEntryId, blankAsNil: true)
        self.checkoutSettings = try? model.container.decode(CheckoutSettings.self, forKey: .checkoutSettings)
        self.insights = try? model.container.decode(InsightsSettings.self, forKey: .insights)
        self.welcome = try? model.container.decode(WelcomeSettings.self, forKey: .welcome)
        self.pricingScreen = try? model.container.decode(PricingScreenSettings.self, forKey: .pricingScreen)
        self.apiDomain = model.optionalString(.apiDomain, blankAsNil: true)
        self.upgradeCopy = try? model.container.decode(UpgradeCopy.self, forKey: .upgradeCopy)
        self.dataExport = try? model.container.decode(DataExportSettings.self, forKey: .dataExport)
        self.journal = try? model.container.decode(JournalSettings.self, forKey: .journal)
        self.coreValuesPath = model.optionalString(.coreValuesPath, blankAsNil: true) ?? "/core-values/embed"
    }
    
}

struct PricingFeature: Codable, Identifiable {
    var id = UUID()
    var icon: String?
    var titleMarkdown: String?
    var descriptionMarkdown: String?
    
    enum PricingFeatureKey: CodingKey {
        case icon
        case titleMarkdown
        case descriptionMarkdown
    }
    
    init() {}
    
    public init(from decoder: Decoder) throws {
        let model = try ModelDecoder<PricingFeatureKey>.create(decoder: decoder, codingKeys: PricingFeatureKey.self)
        self.icon = model.optionalString(.icon, blankAsNil: true)
        self.titleMarkdown =  model.optionalString(.titleMarkdown, blankAsNil: true)
        self.descriptionMarkdown = model.optionalString(.descriptionMarkdown, blankAsNil: true)
    }
    
    static func create(icon: String, title: String?, description: String?) -> PricingFeature {
        var f = PricingFeature()
        f.icon = icon
        f.titleMarkdown = title
        f.descriptionMarkdown = description
        return f
    }
    
    static func create(icon: IconType?, title: String?, description: String?) -> PricingFeature {
        var f = PricingFeature()
        f.icon = icon?.rawValue
        f.titleMarkdown = title
        f.descriptionMarkdown = description
        return f
    }
    
    static func create(icon: Feather.IconName?, title: String?, description: String?) -> PricingFeature {
        var f = PricingFeature()
        f.icon = icon?.rawValue
        f.titleMarkdown = title
        f.descriptionMarkdown = description
        return f
    }
}

let DEFAULT_PRICING_FEATURES: [PricingFeature] = [
    PricingFeature.create(icon: IconType.calendar, title: "Make it daily", description: "Improve your focus and positivity at work and home with a fresh prompt, every day."),
    PricingFeature.create(icon: .pie, title: "Personalized insights", description: "Visualizations reveal the people, places, and things that contribute to your satisfaction."),
    PricingFeature.create(icon: .journal, title: "Look back", description: "As your journal fills up, celebrate and relive the positive forces in your life."),
    PricingFeature.create(icon: IconType.lock, title: "Private + secure", description: "Your journal entries are encrypted for your eyes only."),
]

class PricingScreenSettings: Codable {
    var pageTitleMarkdown: String = "Get more with Cactus Plus"
    var pageDescriptionMarkdown: String = "Daily prompts, personalized insights, and more"
    var purchaseButtonText: String = "Try Cactus Plus"
    var features: [PricingFeature] = DEFAULT_PRICING_FEATURES
    var headerBackgroundHeight: CGFloat? = 260
    
    enum PricingScreenKey: CodingKey {
        case pageTitleMarkdown
        case pageDescriptionMarkdown
        case purchaseButtonText
        case features
        case headerBackgroundHeight
    }
    
    init() {
        //no op
    }
    
    public required init(from decoder: Decoder) throws {
        let model = try ModelDecoder<PricingScreenKey>.create(decoder: decoder, codingKeys: PricingScreenKey.self)
        self.pageTitleMarkdown  = model.string(.pageTitleMarkdown, defaultValue: "Get more with Cactus Plus", blankAsNil: true)
        self.pageDescriptionMarkdown = model.string(.pageDescriptionMarkdown, defaultValue: "Daily prompts, personalized insights, and more", blankAsNil: true)
        self.purchaseButtonText = model.string(.purchaseButtonText, defaultValue: "Try Cactus Plus", blankAsNil: true)
        self.headerBackgroundHeight = model.cgFloat(.headerBackgroundHeight, defaultValue: 260)
        self.features = (try? model.container.decode([PricingFeature].self, forKey: .features)) ?? DEFAULT_PRICING_FEATURES
    }
    
    static func defaultSettings() -> PricingScreenSettings {
        let settings = PricingScreenSettings()
        return settings
    }
}

class DataExportSettings: Codable {
    var enabledTiers: [SubscriptionTier] = []
    
    enum DataExportSettingsField: CodingKey {
        case enabledTiers
    }
    
    public required init(from decoder: Decoder) throws {
        let model = try ModelDecoder<DataExportSettingsField>.create(decoder: decoder, codingKeys: DataExportSettingsField.self)
        self.enabledTiers = (try? model.container.decode([SubscriptionTier].self, forKey: .enabledTiers)) ?? []
    }
    
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
    
    static func defaults() -> JournalHomeUpgradeBannerCopy {
        let copy = JournalHomeUpgradeBannerCopy()
        copy.title = "Try Cactus Plus"
        copy.descriptionMarkdown = "Get daily prompts, personalized insights, and more"
        copy.upgradeButtonText = "Try it free"
        return copy
    }
}

class JournalHomeUpgradeCopyGroups: Codable {
    var basicTier: JournalHomeUpgradeBannerCopy
    
    init(basic: JournalHomeUpgradeBannerCopy) {
        self.basicTier = basic
    }
    
    static func defaults() -> JournalHomeUpgradeCopyGroups {
        let groups = JournalHomeUpgradeCopyGroups(basic: JournalHomeUpgradeBannerCopy.defaults())
        
        return groups
    }
}

class ManageSubscriptionCopy: Codable {
    var upgradeFromOptInTrian: String = ""
    var upgradeFromBasicMarkdown: String = ""
    var upgradeButtonText: String? = "Try Cactus Plus"
    
    static func defaults() -> ManageSubscriptionCopy {
        return ManageSubscriptionCopy()
    }
}

class CelebrateUpgradeCopy: Codable {
    var upgradeBasicDescriptionMarkdown: String? = "Get daily insights and more"
    
    static func defaults() -> CelebrateUpgradeCopy {
        return CelebrateUpgradeCopy()
    }
}

class UpgradeCopy: Codable {
    var journalHomeBanner: JournalHomeUpgradeCopyGroups
    var manageSubscription: ManageSubscriptionCopy
    var celebrate: CelebrateUpgradeCopy
    
    init(banner: JournalHomeUpgradeCopyGroups, subscription: ManageSubscriptionCopy, celebrate: CelebrateUpgradeCopy) {
        self.journalHomeBanner = banner
        self.manageSubscription = subscription
        self.celebrate = celebrate
    }
    
    static func defaults() -> UpgradeCopy {
        let copy = UpgradeCopy(banner: JournalHomeUpgradeCopyGroups.defaults(),
                               subscription: ManageSubscriptionCopy.defaults(),
                               celebrate: CelebrateUpgradeCopy.defaults())
    
        return copy
    }
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

class JournalSettings: Codable {
    var enableAllSentPromptsForTiers: [SubscriptionTier] = []
    
    enum Key: CodingKey {
        case enableAllSentPromptsForTiers
    }
    
    public required init(from decoder: Decoder) throws {
        let model = try ModelDecoder<Key>.create(decoder: decoder, codingKeys: Key.self)
        self.enableAllSentPromptsForTiers = model.subscriptionTierArray(.enableAllSentPromptsForTiers)
    }
}
