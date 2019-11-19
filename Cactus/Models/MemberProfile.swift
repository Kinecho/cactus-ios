//
//  MemberProfile.swift
//  Cactus
//
//  Created by Neil Poulin on 11/19/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation


class MemberProfileField: BaseModelField {
    static let userId = "userId"
    static let cactusMemberId = "cactusMemberId"
    static let email = "email"
    static let isPublic = "isPublic"
    static let firstName = "firstName"
    static let lastName = "lastName"
}
class MemberProfile: FirestoreIdentifiable {
    static var collectionName = FirestoreCollectionName.memberProfiles
    static let Field = MemberProfileField.self
    var id: String?
    var deleted: Bool = false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    var firstName: String?
    var lastName: String?
    var email: String?
    var cactusMemberId: String!
    var userId: String!
    var isPublic: Bool? = true
    var avatarUrl: String?
    
    func getFullName() -> String {
        return "\(self.firstName ?? "") \(self.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
