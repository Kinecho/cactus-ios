//
//  MemberProfileService.swift
//  Cactus
//
//  Created by Neil Poulin on 11/19/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class MemberProfileService {
    let firestoreService: FirestoreService
    let logger = Logger("MemberProfileService")
    static let sharedInstance = MemberProfileService()
    
    var memberUnsubscriber: Unsubscriber?
    var currentMemberProfile: MemberProfile?
    var currentMemberProfileListener: ListenerRegistration?
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            guard let memberId = member?.id  else {
                return
            }
            self.currentMemberProfileListener?.remove()
            self.currentMemberProfileListener = self.observeByMemberId(id: memberId, { (profile, error) in
                if let error = error {
                    self.logger.error("Failed to get current user profile for member Id \(memberId)", error)
                }
                self.logger.info("Setting current member profile to \(String(describing: profile))")
                self.currentMemberProfile = profile
            })
        })
    }
    
    deinit {
        self.memberUnsubscriber?()
        self.currentMemberProfileListener?.remove()
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.memberProfiles)
    }
    
    func getByMemberId(id: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) {
        let query = getCollectionRef().whereField(MemberProfileField.cactusMemberId, isEqualTo: id)
            .whereField(MemberProfileField.isPublic, isEqualTo: true)
        self.firestoreService.getFirst(query, onData)
    }
    
    func observeByMemberId(id: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) -> ListenerRegistration? {
        return self.firestoreService.observeById(id, onData)
    }
    
    func getByUserId(id: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) {
        let query = getCollectionRef().whereField(MemberProfileField.userId, isEqualTo: id)
            .whereField(MemberProfileField.isPublic, isEqualTo: true)
        self.firestoreService.getFirst(query, onData)
    }
    
    func observeByUserId(userId: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) -> ListenerRegistration {
        let query = getCollectionRef().whereField(MemberProfileField.userId, isEqualTo: userId)
            .whereField(MemberProfileField.isPublic, isEqualTo: true)
        return self.firestoreService.observeFirst(query, onData)
    }
    
    func getByEmail(email: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) {
        let query = getCollectionRef().whereField(MemberProfileField.email, isEqualTo: email)
            .whereField(MemberProfileField.isPublic, isEqualTo: true)
        self.firestoreService.getFirst(query, onData)
    }
    
    func observeByEmail(email: String, _ onData: @escaping (MemberProfile?, Any?) -> Void) -> ListenerRegistration {
        let query = getCollectionRef().whereField(MemberProfileField.email, isEqualTo: email)
            .whereField(MemberProfileField.isPublic, isEqualTo: true)
        return self.firestoreService.observeFirst(query, onData)
    }
}
