//
//  CactusMemberService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class CactusMemberService {
    
    let firestoreService: FirestoreService
    var memberListener: (() -> Void)?
    var currentMember: CactusMember?
    static let sharedInstance = CactusMemberService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
        self.memberListener = self.observeCurrentMember { (member, _) in
            
            if let member = member, member != self.currentMember {
                DispatchQueue.main.async {
                    self.addFCMToken(member: member)
                }
            }
            self.currentMember = member
        }
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.members)
    }
    
    func removeFCMToken(onCompleted: @escaping (_ error: Any?) -> Void) {
        guard let member = self.currentMember else {
            onCompleted(nil)
            return
        }

        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                let token = result.token
                var tokens = member.fcmTokens ?? []
                if !tokens.contains(token) {
                    print("Token not on member, not doing anything")
                    onCompleted(nil)
                    return
                }
                tokens.removeAll(where: { $0 == token})
                print("Updated tokens are \(tokens.joined(separator: " | "))")
                member.fcmTokens = tokens
                self.firestoreService.save(member, onComplete: { (savedMember, error) in
                    if let error = error {
                        print("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
                        
                    } else {
                        print("Successfully removed existing token on cactus member \(savedMember?.fcmTokens?.joined(separator: " | " ) ?? "NO Tokens")")
                    }
                    onCompleted(error)
                })
            }
        }
    }
    
    func addFCMToken(member: CactusMember) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                let token = result.token
                var tokens = member.fcmTokens ?? []
                if tokens.contains(token) {
                    print("Token already exists on user, not doing anything")
                    return
                }
                tokens.append(token)
                member.fcmTokens = tokens
                self.firestoreService.save(member, onComplete: { (_, error) in
                    if let error = error {
                        print("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
                    } else {
                        print("Successfully updated tokens on cactus member")
                    }
                    
                })
            }
        }
    }
    
    func observeCurrentMember( _ onData: @escaping (CactusMember?, Any?) -> Void) -> (() -> Void) {
        var memberUnsub: ListenerRegistration?
        let authUnsub = AuthService.sharedInstance.getAuthStateChangeHandler { (_, user) in
            _ = memberUnsub?.remove()
            if let user = user {
                print("observeCurrentMember: got user")
                let query = self.getCollectionRef().whereField(CactusMember.Field.userId, isEqualTo: user.uid).limit(to: 1)
                memberUnsub = self.firestoreService.addListener(query) { (members: [CactusMember]?, error) in
                    print("observeCurrentMember: got member? \(members?.first?.email ?? "no email")")
                    onData(members?.first, error)
                }
            } else {
                print("observeCurrentMember: no user found")
                onData(nil, nil)
            }
        }
        
        return {
            AuthService.sharedInstance.removeAuthStateChangeListener(authUnsub)
            memberUnsub?.remove()
        }
        
    }

    func getCurrentMember() -> CactusMember? {
        return self.currentMember
    }
    
    func getById(id: String) {
        
    }
}
