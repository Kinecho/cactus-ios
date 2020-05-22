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
import FirebaseAuth

protocol InstanceIDDelegate: class {
    func getInstanceId(_ completed: @escaping (_ token: String, _ id: String) -> Void)
}

class CactusMemberService {
    
    let firestoreService: FirestoreService
    var memberListener: Unsubscriber?
    var currentMember: CactusMember?
    var currentUser: User?
    weak var instanceIDDelegate: InstanceIDDelegate?
    static let sharedInstance = CactusMemberService()
    let logger = Logger("CactusMemberService")
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
        self.memberListener = self.observeCurrentMember { (member, _, user) in
            
            if let member = member, member != self.currentMember {
                DispatchQueue.main.async {
                    self.addFCMToken(member: member)
                    self.setTimeZone(member: member)
                }
            }
            self.currentUser = user
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

        self.instanceIDDelegate?.getInstanceId { token, id in
//            let id = result.instanceID
            var tokens = member.fcmTokens ?? []
            var ids = member.firebaseInstanceIds ?? []
            let hasToken = tokens.contains(token)
            let hasId = ids.contains(id)
            if !hasToken && !hasId {
                self.logger.debug("Token or ID not on member, not doing anything")
                onCompleted(nil)
                return
            }
            tokens.removeAll(where: { $0 == token})
            ids.removeAll(where: { $0 == id })
            
            self.logger.debug("Updated tokens are \(tokens.joined(separator: " | "))")
            member.fcmTokens = tokens
            member.firebaseInstanceIds = ids
            self.firestoreService.save(member, onComplete: { (savedMember, error) in
                if let error = error {
                    self.logger.error("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
                } else {
                    self.logger.info("Successfully removed existing token on cactus member \(savedMember?.fcmTokens?.joined(separator: " | " ) ?? "NO Tokens")")
                }
                onCompleted(error)
            })
        }
        
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                self.logger.error("Error fetching remote instance ID: \(error)")
//            } else if let result = result {
//                let token = result.token
//                let id = result.instanceID
//                var tokens = member.fcmTokens ?? []
//                var ids = member.firebaseInstanceIds ?? []
//                let hasToken = tokens.contains(token)
//                let hasId = ids.contains(id)
//                if !hasToken && !hasId {
//                    self.logger.debug("Token or ID not on member, not doing anything")
//                    onCompleted(nil)
//                    return
//                }
//                tokens.removeAll(where: { $0 == token})
//                ids.removeAll(where: { $0 == id })
//
//                self.logger.debug("Updated tokens are \(tokens.joined(separator: " | "))")
//                member.fcmTokens = tokens
//                member.firebaseInstanceIds = ids
//                self.firestoreService.save(member, onComplete: { (savedMember, error) in
//                    if let error = error {
//                        self.logger.error("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
//                    } else {
//                        self.logger.info("Successfully removed existing token on cactus member \(savedMember?.fcmTokens?.joined(separator: " | " ) ?? "NO Tokens")")
//                    }
//                    onCompleted(error)
//                })
//            }
//        }
    }
    
    func save(_ member: CactusMember, completed: @escaping (CactusMember?, Any?) -> Void) {
        self.firestoreService.save(member, onComplete: completed)
    }
    
    func addFCMToken(member: CactusMember) {
        self.instanceIDDelegate?.getInstanceId { (token, instanceId) in
//            let instanceId = result.instanceID
            var tokens = member.fcmTokens ?? []
            var ids = member.firebaseInstanceIds ?? []
            let hasToken = tokens.contains(token)
            let hasId = ids.contains(instanceId)
            if hasToken && hasId {
                self.logger.debug("Member already has instance id and token")
                return
            }
            
            if !hasToken {
                tokens.append(token)
            }
            
            if !hasId {
                ids.append(instanceId)
            }
            
            member.fcmTokens = tokens
            member.firebaseInstanceIds = ids
            
            self.firestoreService.save(member, onComplete: { (_, error) in
                if let error = error {
                    self.logger.error("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
                } else {
                    self.logger.info("Successfully updated tokens on cactus member")
                }
            })
        }
        
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                self.logger.error("Error fetching remote instance ID: \(error)")
//            } else if let result = result {
//                let token = result.token
//                let instanceId = result.instanceID
//                var tokens = member.fcmTokens ?? []
//                var ids = member.firebaseInstanceIds ?? []
//                let hasToken = tokens.contains(token)
//                let hasId = ids.contains(instanceId)
//                if hasToken && hasId {
//                    self.logger.debug("Member already has instance id and token")
//                    return
//                }
//
//                if !hasToken {
//                    tokens.append(token)
//                }
//
//                if !hasId {
//                    ids.append(instanceId)
//                }
//
//                member.fcmTokens = tokens
//                member.firebaseInstanceIds = ids
//
//                self.firestoreService.save(member, onComplete: { (_, error) in
//                    if let error = error {
//                        self.logger.error("Failed to set FCM Tokens on Cactus Member \(member.id ?? "unknown member id")", error)
//                    } else {
//                        self.logger.info("Successfully updated tokens on cactus member")
//                    }
//                })
//            }
//        }
    }
    
    /**
     Update the member's timezone if they do not already have one.
     */
    func setTimeZone(member: CactusMember, timeZone: String?=nil) {
        
        guard member.timeZone == nil else {
            self.logger.info("the member already has a timezone set, not setting it", functionName: #function, line: #line)
            return
        }
        
        member.timeZone = timeZone ?? Calendar.current.timeZone.identifier
        self.save(member) { (_, error) in
            if let error = error {
                self.logger.error("Failed to update the user's timezone", error)
            }
        }
    }
    
    /**
     Add a listener for the current Cactus Member, based on the current auth user.
     When the auth user changes (i.e. logs out or logs in), the data callback handler will be updated with the latest values
        - Parameters onData: The data handler
        - Returns: an Unsubscriber function
     */
    func observeCurrentMember( _ onData: @escaping (CactusMember?, Any?, User?) -> Void) -> Unsubscriber {
        var memberUnsub: ListenerRegistration?
        var _user: User?
        let authUnsub = AuthService.sharedInstance.getAuthStateChangeHandler { (_, user) in
            
            if let user = user, _user?.uid == nil || _user?.uid != user.uid {
                memberUnsub?.remove()
                let query = self.getCollectionRef().whereField(CactusMember.Field.userId, isEqualTo: user.uid).limit(to: 1)
                memberUnsub = self.firestoreService.addListener(query) { (members: [CactusMember]?, error) in
                    self.logger.info("observeCurrentMember: got member? \(members?.first?.email ?? "no email")")
                    onData(members?.first, error, user)
                }
            } else if user == nil {
                memberUnsub?.remove()
                self.logger.info("observeCurrentMember: no user found")
                onData(nil, nil, nil)
            }
            _user = user
        }
        
        return {
            AuthService.sharedInstance.removeAuthStateChangeListener(authUnsub)
            memberUnsub?.remove()
        }
        
    }

    func getCurrentMember() -> CactusMember? {
        return self.currentMember
    }
    
    func awaitCurrentUser(_ onCompleted: @escaping (User?) -> Void) {
        let task = AuthenticatedTask { (_, user, taskCompleted) in
            defer {
                taskCompleted()
            }
            onCompleted(user)
        }
        AuthenticatedTaskManager.shared.addTask(task)
    }
    
    func getById(id: String) {
        
    }
}
