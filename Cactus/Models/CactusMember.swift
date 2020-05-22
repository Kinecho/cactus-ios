//
//  CactusMember.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
//import UIKit

public class CactusMemberField: BaseModelField {
    static public let email = "email"
    static public let firstName = "firstName"
    static public let lastName = "lastName"
    static public let userId = "userId"
    static public let notificationSettings = "notificationSettings"
}

enum NotificationSettingType: String, Codable {
    case email
    case push
}

enum NotificationStatus: String, Codable {
    case NOT_SET
    case ACTIVE
    case INACTIVE
}

struct ElementAccumulation: Codable {
    var emotions: Int = 0
    var energy: Int = 0
    var experience: Int = 0
    var meaning: Int = 0
    var relationships: Int = 0
    
    func getElement(_ element: CactusElement) -> Int {
        switch element {
        case .emotions:
            return self.emotions
        case .energy:
            return self.energy
        case .meaning:
            return self.meaning
        case .experience:
            return self.experience
        case .relationships:
            return self.relationships            
        }
    }
}

struct InsightWord: Codable {
    var frequency: Int = 0
    var word: String = ""
}

enum StreakDuration: String, Codable {
    case DAYS
    case WEEKS
    case MONTHS
    
    func getLabel(count: Int) -> String {
        let plural = count == 0 || count > 1
        return plural ? self.pluralLabel : self.singularLabel
    }
    
    var singularLabel: String {
        switch self {
        case .DAYS:
            return "Day"
        case .MONTHS:
            return "Month"
        case .WEEKS:
            return "Week"
        }
    }
    
    var pluralLabel: String {
        switch self {
        case .DAYS:
            return "Days"
        case .MONTHS:
            return "Months"
        case .WEEKS:
            return "Weeks"
        }
    }
}

struct StreakInfo: Codable {
    var count: Int = 0
    var duration: StreakDuration
    
    init(count: Int, duration: StreakDuration) {
        self.count = count
        self.duration = duration
    }
    
}
struct ReflectionStats: Codable {
    var currentStreakDays: Int = 0
    var currentStreakWeeks: Int = 0
    var currentStreakMonths: Int = 0
    var totalDurationMs: Int = 0
    var totalCount: Int = 0
    var elementAccumulation: ElementAccumulation
    
    ///computed
    var currentStreakInfo: StreakInfo {
        if self.currentStreakDays > 1 {
            return StreakInfo(count: self.currentStreakDays, duration: .DAYS)
        }
        if self.currentStreakWeeks > 1 {
            return StreakInfo(count: self.currentStreakWeeks, duration: .WEEKS)
        }
        if self.currentStreakMonths > 1 {
            return StreakInfo(count: self.currentStreakMonths, duration: .MONTHS)
        }
        return StreakInfo(count: self.currentStreakDays, duration: .DAYS)
    }
    
}

struct MemberStats: Codable {
    var reflections: ReflectionStats?
}

struct PromptSendTime: Codable {
    var hour: Int
    var minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

struct MemberStripeDetails: Codable {
    var customerId: String?
}

class CactusMember: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.members
    static let Field = CactusMemberField.self

    var firstName: String?
    var lastName: String?
    var email: String?
    var userId: String?
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var fcmTokens: [String]?
    var firebaseInstanceIds: [String]?
    var mailchimpListMember: ListMember?
    var notificationSettings: [String: String]? = [:]
    var stats: MemberStats?
    var timeZone: String?
    var locale: String?
    var promptSendTime: PromptSendTime?
    var subscription: MemberSubscription?
    var stripe: MemberStripeDetails?
    var wordCloud: [InsightWord]?
     var coreValues: [String]?
    
    static func == (lhs: CactusMember, rhs: CactusMember) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    //computed properties
    var tier: SubscriptionTier {
        return self.subscription?.tier ?? SubscriptionTier.BASIC
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    func getPreferredTimeZone() -> TimeZone? {
        guard let userTimeZone = self.timeZone else {
            return nil
        }
        
        return TimeZone(identifier: userTimeZone)
    }
    
    func getCoreValue(at preferredIndex: Int? = nil) -> String? {
        let valuesSize = self.coreValues?.count ?? 0
        guard !(self.coreValues?.isEmpty ?? true), valuesSize > 0 else {
            return nil
        }
        
        let index = (preferredIndex ?? 0) % valuesSize
        return self.coreValues?[index]
    }
}
