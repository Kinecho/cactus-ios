//
//  SubscriptionUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

func getDisplayName(_ tier: SubscriptionTier) -> String {
    switch tier {
    case .PLUS:
        return "Plus"
    case .BASIC:
        return "Basic"
    case .PREMIUM:
        return "Premium"
    default:
        return ""
    }
}
