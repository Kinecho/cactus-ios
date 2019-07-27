//
//  ReflectionPromptService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore
class ReflectionPromptService {
    
    let firestoreService: FirestoreService
    
    static let sharedInstance = ReflectionPromptService();
    
    private init(){
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.reflectionPrompt)
    }
    
    func observeById(id:String, _ onData: @escaping (ReflectionPrompt?, Any?) -> Void) -> ListenerRegistration? {
        return self.firestoreService.observeById(id, onData)
    }
}
