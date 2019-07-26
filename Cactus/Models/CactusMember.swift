//
//  CactusMember.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

public class CactusMemberField:BaseModelField {
    
    static public let email = "email"
    static public let firstName = "firstName"
    static public let lastName = "lastName"
    static public let userId = "userId"
}

class CactusMember:FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.members
    static let Field = CactusMemberField.self
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var userId: String?
    
    var id : String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    static func == (lhs: CactusMember, rhs: CactusMember) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        id.hash(into: &hasher)
    }
    
}
