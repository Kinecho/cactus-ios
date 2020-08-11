//
//  StringConstants.swift
//  Cactus
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import SwiftUI
/// Localizeable String Keys that do not require any formatting parameters and can be rendered on their own. These values are definied in the Localizable.strings file
enum StringKey: String, Codable, CaseIterable {
    case Cactus
    case Streak
    case Reflections
    case Duration
    case LogOut
    case LogOutConfirm
    case Home
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
    
    var key: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
}

/// Localizable String Keys that require a format value to render correclty, such as number of days. These values are definied in the Localizable.stringsdict file
enum StringDictKey: String, Codable, CaseIterable {
    case unitSecond
    case unitMinute
    case unitHour
    case unitDay
    case unitWeek
    case unitMonth
    case unitYear
    
    case numberOfSeconds
    case numberOfMinutes
    case numberOfHours
    case numberOfDays
    case numberOfWeeks
    case numberOfMonths
    case numberOfYears
    
    func formatted(_ param: CVarArg) -> String {
        let formatString = NSLocalizedString(self.rawValue, comment: self.rawValue)
        return String(format: formatString, param)
    }
}

struct UnitKey {
    static let second = StringDictKey.unitSecond
    static let minute = StringDictKey.unitMinute
    static let hour = StringDictKey.unitHour
    static let day = StringDictKey.unitDay
    static let week = StringDictKey.unitWeek
    static let month = StringDictKey.unitMonth
    static let year = StringDictKey.unitYear
}

struct DurationKey {
    static let seconds = StringDictKey.numberOfSeconds
    static let minutes = StringDictKey.numberOfMinutes
    static let hours = StringDictKey.numberOfHours
    static let days = StringDictKey.numberOfDays
    static let weeks = StringDictKey.numberOfWeeks
    static let months = StringDictKey.numberOfMonths
    static let years = StringDictKey.numberOfYears
}
    
struct UnitFormatter {
    let durationKey: StringDictKey
    let unitKey: StringDictKey
        
    static let second = UnitFormatter(durationKey: .numberOfSeconds, unitKey: .unitSecond)
    static let minute = UnitFormatter(durationKey: .numberOfMinutes, unitKey: .unitMinute)
    static let hour = UnitFormatter(durationKey: .numberOfHours, unitKey: .unitHour)
    static let day = UnitFormatter(durationKey: .numberOfDays, unitKey: .unitDay)
    static let week = UnitFormatter(durationKey: .numberOfWeeks, unitKey: .unitWeek)
    static let month = UnitFormatter(durationKey: .numberOfMonths, unitKey: .unitMonth)
    static let year = UnitFormatter(durationKey: DurationKey.years, unitKey: UnitKey.year)
}

struct LocalizedUnit {
    let unitFormatter: UnitFormatter
    let value: Int
    
    init(_ unit: UnitFormatter, _ value: Int) {
        self.unitFormatter = unit
        self.value = value
    }
    
    var localizedText: LocalizedText {
        LocalizedText(string: self.string)
    }
    
    var string: String {
        self.unitFormatter.durationKey.formatted(self.value)
    }
    
    var unitsOnly: String {
        self.unitFormatter.unitKey.formatted(self.value)
    }
    
    static func second(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.second, value)
    }
    
    static func minute(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.minute, value)
    }
    
    static func hour(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.hour, value)
    }
    
    static func day(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.day, value)
    }
    
    static func week(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.week, value)
    }
    
    static func month(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.month, value)
    }
    
    static func year(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.year, value)
    }
    
    static func fromMiliseconds(_ ms: Int) -> LocalizedUnit {
        let seconds = Int(round(Float(ms) / 1000))
        let minutes = Int(round(Float(seconds) / 60))
        let hours = Int(round(Float(minutes) / 60))
        if seconds < 60 {
            return .second(seconds)
        } else if minutes < 300 {
            return .minute(minutes)
        } else {
            return .hour(hours)
        }        
    }
}

struct LocalizedText {
    let string: String
    
    init(string: String) {
        self.string = string
    }
    
    init(_ key: StringKey) {
        self.init(string: key.localized())
    }
    
    init(_ unit: LocalizedUnit) {
        self = unit.localizedText
    }
    
    static func numberOfDays(_ days: Int) -> LocalizedText {
        return LocalizedText(string: StringDictKey.numberOfDays.formatted(days))
    }
    
//    static func unit(_ unit: LocalizedUnit) -> LocalizedText {
////        return unit.key.formatted(unit.)
//
//    }
}
