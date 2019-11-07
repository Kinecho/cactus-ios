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
    var mailchimpListMember: ListMember?
    var languageCode: String?
    var notificationSettings: [String: String]? = [:]

    var stats: MemberStats?
    
    static func == (lhs: CactusMember, rhs: CactusMember) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
