//
//  ApiTypes.swift
//  Cactus
//
//  Created by Neil Poulin on 10/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct MagicLinkRequest: Codable {
    var email: String
    var continuePath: String
    var referredBy: String?
//    var reflectionResponseIds: String[]?
//    var queryParams: [String: String]
    
    init(email: String, continuePath: String, referredBy: String? = nil) {
        self.email = email
        self.continuePath = continuePath
        self.referredBy = referredBy
    }
}

struct MagicLinkResponse: Codable {
    var exists: Bool = false
    var success: Bool = false
    var email: String
    var error: String?
    var message: String?
    
    init(email: String, success: Bool, exists: Bool=false, message: String?=nil, error: String?=nil) {
        self.email = email
        self.success = success
        self.message = message
        self.error = error
        self.exists = exists
    }
}

struct LoginEvent: Codable {
    var userId: String?
    var isNewUser: Bool = false
    var providerId: String?
    var referredByEmail: String?
    var signupQueryParams: [String: String]?
    var reflectionResponseIds: [String]?
    var email: String?
}

enum ListMemberStatus: String, Codable {
    case subscribed
    case unsubscribed
    case cleaned
    case pending
}

struct EmailNotificationStatusRequest: Codable {
    var status: ListMemberStatus = .subscribed
    var email: String
    
    init(_ email: String, status: ListMemberStatus = .subscribed) {
        self.status = status
        self.email = email
    }
}

struct EmailNotificationStatusResponseError: Codable {
    var title: String?
    var message: String?
    
    init(_ message: String?) {
        self.message = message
    }
}

struct EmailNotificationStatusResponse: Codable {
    var success: Bool = false
    var error: EmailNotificationStatusResponseError?
    enum CodingKeys: CodingKey {
        case success
        case error
    }
    
    init() {
        
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.success = (try? values.decode(Bool.self, forKey: .success)) ?? false
        if let errorString = try? values.decode(String.self, forKey: .error) {
            self.error = EmailNotificationStatusResponseError(errorString)
        } else {
            self.error = try? values.decode(EmailNotificationStatusResponseError.self, forKey: .error)
        }
    }
    
    var errorMessage: String? {
        return self.error?.message
    }
    
    var isInComplianceState: Bool? {
        return self.error?.title?.contains("Member In Compliance State")
    }
    
}
