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
    
    static func fromReflectionStats(stats: ReflectionStats, type: StatType) -> Stat {
        var stat = Stat(type: type, value: 0, unit: nil)
        switch type {
        case .streak:
            stat.value = stats.currentStreakInfo.count
            stat.unit = stats.currentStreakInfo.duration.unitFormatter
        case .reflectionDuration:
            let unit = LocalizedUnit.fromMiliseconds(stats.totalDurationMs)
            stat.unit = unit.unitFormatter
            stat.value = unit.value
        case .reflectionCount:
            stat.value = stats.totalCount
            stat.unit = .none
        }
        
        return stat
    }
    
    static func fromReflectionStats(stats: ReflectionStats) -> [Stat] {
        return StatType.allCases.map { Stat.fromReflectionStats(stats: stats, type: $0) }
   }
}

enum StatType: String, CaseIterable {
    case streak
    case reflectionCount
    case reflectionDuration
    
    var iconName: String {
        switch self {
        case .streak:
            return IconType.flame.rawValue
        case .reflectionDuration:
            return Feather.IconName.clock.rawValue
        case .reflectionCount:
            return IconType.journal.rawValue
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


