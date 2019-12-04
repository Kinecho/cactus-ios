//
//  DateUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

func numDaysAgoFromMidnight(_ date: Date, _ today: Date) -> Int {
    let diffInDays = Calendar.current.dateComponents([.day], from: date, to: today).day
    return diffInDays ?? 0
}

func getDenverCalendar() -> Calendar {
    var denverCalendar = Calendar.current
    let denverTz = getDenverTimeZone()
    denverCalendar.timeZone = denverTz
    return denverCalendar
}

func getDeviceTimeZone() -> TimeZone {
    return Calendar.current.timeZone
}

func getTimeZoneFulllName(_ tz: TimeZone, date: Date = Date(), locale: Locale = Locale.current) -> String? {
    if tz.isDaylightSavingTime(for: date) {
        return tz.localizedName(for: .daylightSaving, locale: locale)
    } else {
        return tz.localizedName(for: .standard, locale: locale)
    }
}

func getTimeZoneShortName(_ tz: TimeZone, date: Date = Date(), locale: Locale = Locale.current) -> String? {
    if tz.isDaylightSavingTime(for: date) {
        return tz.localizedName(for: .shortDaylightSaving, locale: locale)
    } else {
        return tz.localizedName(for: .shortStandard, locale: locale)
    }
}

func getTimeZoneGenericName(_ tz: TimeZone, locale: Locale = Locale.current) -> String? {
    return tz.localizedName(for: .generic, locale: locale)
}

func getTimeZoneGenericNameShort(_ tz: TimeZone, locale: Locale = Locale.current) -> String? {
    return tz.localizedName(for: .shortGeneric, locale: locale)
}

func getMemberCalendar(member: CactusMember?) -> Calendar {
    guard let tz = member?.getPreferredTimeZone() else {
        return getDenverCalendar()
    }
    var memberCalendar = Calendar.current
    memberCalendar.timeZone = tz
    return memberCalendar
}

func getDenverTimeZone() -> TimeZone {
    let denverTz = TimeZone(identifier: "America/Denver")!
    return denverTz
}

func getDefaultNotificationDate(member: CactusMember?) -> Date? {
    let hour = member?.promptSendTime?.hour ?? 2
    let minute = member?.promptSendTime?.minute ?? 45
        
    return getMemberCalendar(member: member).date(bySettingHour: hour, minute: minute, second: 0, of: Date())
}

func calculateStreak(_ dates: [Date]) -> Int {
    if dates.isEmpty {
        return 0
    }
    let dates = dates.sorted { (d1, d2) -> Bool in
        return d1.compare(d2) == .orderedDescending
    }
    var currentDate = Date()
    guard var next = dates.first else {
        return 0
    }
    var i: Int = 1
    var streak: Int = 0
    let dateCount = dates.count
    var diff = numDaysAgoFromMidnight(next, currentDate)
    
    if diff < 2 {
        streak += 1
    }
    
    while i < dateCount && diff < 2 {
        currentDate = next
        next = dates[i]
        diff = numDaysAgoFromMidnight(next, currentDate)
        if diff > 0 && diff < 2 {
            streak += 1
        }
        i += 1
    }

    return streak
}

func calculateStreak(_ reflections: [ReflectionResponse]?) -> Int {
    guard let reflections = reflections, !reflections.isEmpty else {
        return 0
    }
    
//    var dates: [Date] = reflections.compactMap { (reflection) -> Date? in
//        return reflection.createdAt
//    }
    
    var dates = [Date]()
    
    reflections.forEach { (reflection) in
        if let updated = reflection.updatedAt {
            dates.append(updated)
        }
        
        if let created = reflection.createdAt {
            dates.append(created)
        }
    }
    
    return calculateStreak(dates)
}
