//
//  SubscriptionCopy.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

struct JournalBannerCopy {
    var title: String?
    var description: String?
    var buttonText: String?
}

struct SubscriptionCopy {
    static func journalBannerText(_ member: CactusMember?, settings: AppSettings?) -> JournalBannerCopy? {
        guard let member = member, let settings = settings, let copy = settings.upgradeCopy?.journalHomeBanner else {
            return nil
        }
        
        let isActivated = member.subscription?.isActivated ?? false
        let inTrial = member.subscription?.isInOptInTrial ?? false
        let daysLeft = member.subscription?.trialDaysLeft
        if isActivated || member.tier.isPaidTier {
            return nil
        }
        
        var title: String?
        var description: String?
        let buttonText: String? = copy.basicTier.upgradeButtonText
        if inTrial {
            if daysLeft == 1 {
                title = "Trial ends today"
            } else {
                title = "\(daysLeft ?? 0) days left in trial"
            }
        } else {
            title = copy.basicTier.title
            description = copy.basicTier.descriptionMarkdown
        }
        
        return JournalBannerCopy(title: title, description: description, buttonText: buttonText)
    }
}
