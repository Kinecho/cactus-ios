//
//  Stats.swift
//  Cactus
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import NoveFeatherIcons

struct Stat: Identifiable {
    let id = UUID()
    var type: StatType
    var value: Int
    var unit: UnitFormatter?
}

enum StatType: String {
    case streak
    case reflectionDuration
    case reflectionCount
    
    var iconName: Feather.IconName {
        switch self {
        case .streak:
            return .coffee
        case .reflectionDuration:
            return .clock
        case .reflectionCount:
            return .bookOpen
        }
    }
    
    var displayName: String {
        switch self {
        case .streak:
            return LocalizedText.init(.Streak).string
        case .reflectionDuration:
            return LocalizedText.init(.Duration).string
        case .reflectionCount:
            return LocalizedText.init(.Reflections).string
        }
    }
}


