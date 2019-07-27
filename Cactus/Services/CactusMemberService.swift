//
//  CactusMemberService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore
class CactusMemberService {
    
    let firestoreService: FirestoreService
    var memberListener: (() -> Void)?
    var currentMember:CactusMember?
    static let sharedInstance = CactusMemberService();
    
    private init(){
        self.firestoreService = FirestoreService.sharedInstance
        
        self.memberListener = self.observeCurrentMember { (member, error) in
            self.currentMember = member
        }
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.members)
    }
    
    func observeCurrentMember( _ onData: @escaping (CactusMember?, Any?) -> Void) -> (() -> Void) {
        var memberUnsub: ListenerRegistration?
        let authUnsub = AuthService.sharedInstance.getAuthStateChangeHandler { (auth, user) in
            _ = memberUnsub?.remove()
            if let user = user {
                let query = self.getCollectionRef().whereField(CactusMember.Field.userId, isEqualTo: user.uid).limit(to: 1)
                memberUnsub = self.firestoreService.addListener(query) { (members: [CactusMember]?, error) in
                    onData(members?.first, error)
                }
            } else {
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
    
    func getById(id:String) {
        
    }
}
