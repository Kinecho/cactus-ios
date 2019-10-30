//
//  SentPromptService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class SentPromptService {
    
    let firestoreService: FirestoreService
    
    static let sharedInstance = SentPromptService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.sentPrompts)
    }
    
    func observeSentPrompts(member: CactusMember, _ onData: @escaping ([SentPrompt]?, Any?) -> Void) -> ListenerRegistration? {
        guard let memberId = member.id else {
            onData(nil, "No member ID found")
            return nil
        }
        
        let query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
        
        return self.firestoreService.addListener(query, { (sentPrompts, error) in
            onData(sentPrompts, error)
        })
    }
    
    func getSentPrompts(member: CactusMember, limit: Int? = nil, _ completed: @escaping ([SentPrompt]?, Any?) -> Void) {
        guard let memberId = member.id else {
            completed(nil, "No member ID found")
            return
        }
        
        var query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
            
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        return self.firestoreService.executeQuery(query, { (sentPrompts, error) in
            completed(sentPrompts, error)
        })
    }
}
