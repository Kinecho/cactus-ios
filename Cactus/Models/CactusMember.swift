//
//  CactusMember.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

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

struct ReflectionStats: Codable {
    var currentStreakDays: Int = 0
    var totalDurationMs: Int = 0
    var totalCount: Int = 0
    var elementAccumulation: ElementAccumulation
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
    
    static func == (lhs: CactusMember, rhs: CactusMember) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
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
}
