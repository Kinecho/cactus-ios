//
//  StringConstants.swift
//  Cactus
//
//  Created by Neil Poulin on 8/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

/// Localizeable String Keys that do not require any formatting parameters and can be rendered on their own. These values are definied in the Localizable.strings file
enum StringKey: String, Codable, CaseIterable {
    case Cactus
    case Streak
    case Reflections
    case Duration
    case LogOut
    case LogOutConfirm
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
}

/// Localizable String Keys that require a format value to render correclty, such as number of days. These values are definied in the Localizable.stringsdict file
enum StringDictKey: String, Codable, CaseIterable {
    case numberOfDays
    case numberOfMinutes
    case unitMinute
    case unitDay
    
    func formatted(_ param: CVarArg) -> String {
        let formatString = NSLocalizedString(self.rawValue, comment: self.rawValue)
        return String(format: formatString, param)
    }
}



//enum LocalizableUnit {
//    case day(Int)
//
//    var key: StringDictKey {
//        switch self {
//        case .day:
//            return .numberOfDays
//        }
//    }
//
//    var value: Int {
//        switch self {
//        case let .day(value):
//            return value
//    }
//
//    var localizedText: LocalizedText {
//        switch self {
//        case .day(let days):
//            return LocalizedText(string: StringDictKey.numberOfDays.formatted(days))
//        }
//    }
//}
    
struct UnitFormatter {
    let numberKey: StringDictKey
    let unitKey: StringDictKey
    
    static let day = UnitFormatter(numberKey: .numberOfDays, unitKey: .unitDay)
    static let minute = UnitFormatter(numberKey: .numberOfMinutes, unitKey: .unitMinute)
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
        self.unitFormatter.numberKey.formatted(self.value)
    }
    
    var unitsOnly: String {
        self.unitFormatter.unitKey.formatted(self.value)
    }
    
    static func day(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.day, value)
    }
    
    static func minute(_ value: Int) -> LocalizedUnit {
        return LocalizedUnit(.minute, value)
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
