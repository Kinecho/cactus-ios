//
//  BaseModel.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation


public enum FirestoreCollectionName:String {
    case members
    case users
    case reflectionPrompt
    case sentPrompts
}


public class BaseModelField {
    static let collectionName = "collectionName"
    static let id = "id"
    
    static let deleted = "deleted"
    static let deletedAt = "deletedAt"
    
    static let createdByUserId = "createdByUserId"
    static let updatedByUserId = "updatedByUserId"
    
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
}

public enum BaseModelEnum {
    case collectionName
    case id
    case deleted
    case deletedAt
    case createdByUserId
    case updatedByUserId
    case createdAt
    case updatedAt
}

protocol FirestoreIdentifiable: BaseModelProtocol {
    static var collectionName : FirestoreCollectionName {get}
}


protocol BaseModelProtocol:Codable {
    var id : String? {get set}
    var deleted: Bool {get set}
    var deletedAt: Date? {get set}
    var createdAt: Date? {get set}
    var updatedAt: Date? {get set}
}



protocol FirestoreOwnable: FirestoreIdentifiable {
    var createdByUserId: String? {get set}
    var updatedByUserId: String? {get set}
}
