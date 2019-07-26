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

    static let sharedInstance = CactusMemberService();
    
    private init(){
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.members)
    }
    
    func getCurrentMember(_ onData: @escaping (CactusMember?, Any?) -> Void) -> Void {
        guard let user = AuthService.sharedInstance.getCurrentUser() else {
            return onData(nil, nil)
        }
        let query = self.getCollectionRef().whereField(CactusMember.Field.userId, isEqualTo: user.uid).limit(to: 1)
        
        self.firestoreService.getFirst(query, onData)
    }
    
    func getById(id:String) {
        
    }
}
