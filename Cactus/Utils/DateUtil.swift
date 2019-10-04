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
