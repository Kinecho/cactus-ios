//
//  SocialInviteService.swift
//  Cactus
//
//  Created by Neil Poulin on 1/17/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class SocialInviteService {
    
    let firestoreService: FirestoreService
    let apiService: ApiService
    let logger = Logger("SocialInviteService")
    static let sharedInstance = SocialInviteService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
        self.apiService = ApiService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.socialInvites)
    }
    
    func sendInvites(to contacts: [SocialContact], from member: CactusMember, message: String?=nil, _ onCompleted: @escaping (SocialInviteResponse?, Any?) -> Void) {
        var emailContacts: [EmailContact] = []
        contacts.forEach { (socialContact) in
            if let emailContact = EmailContact.from(contact: socialContact) {
                emailContacts.append(emailContact)
            }
        }
        
        let inviteRequest = SocialInviteRequest(to: emailContacts, message: message)
        self.logger.info("SocialInviteRequest \(inviteRequest)")
        
        self.apiService.post(path: ApiPath.sendSocialInvite, body: inviteRequest, responseType: SocialInviteResponse.self, authenticated: true) {response, error in
            if let error = error {
                self.logger.error("Failed to send invites", error)
                onCompleted(nil, error)
                return
            }
            if response?.success != true {
                self.logger.error("Send invites returned success false but no error: \(String(describing: response))")
            }
            onCompleted(response, nil)
        }
        
    }
    
}
