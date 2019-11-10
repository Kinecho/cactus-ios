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
    
    func observeSentPrompts(member: CactusMember, limit: Int?=nil, _ onData: @escaping ([SentPrompt]?, Any?) -> Void) -> ListenerRegistration? {
        guard let memberId = member.id else {
            onData(nil, "No member ID found")
            return nil
        }
        
        var query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        return self.firestoreService.addListener(query, { (sentPrompts, error) in
            onData(sentPrompts, error)
        })
    }
    
    func observeSentPromptsPage(member: CactusMember,
                                beforeOrEqualTo: Date?=nil,
                                limit: Int?=nil,
                                lastResult: PageResult<SentPrompt>?=nil,
                                _ onData: @escaping (PageResult<SentPrompt>) -> Void) -> ListenerRegistration? {
        guard let memberId = member.id else {
            var result = PageResult<SentPrompt>()
            result.error = "No Member ID found on cactus member"
            onData(result)
            return nil
        }
        
        var query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
        
        if let before = beforeOrEqualTo {
            query.whereField(SentPrompt.Field.firstSentAt, isLessThanOrEqualTo: Timestamp(date: before))
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        return self.firestoreService.addPaginatedListener(query, limit: limit, lastResult: lastResult, onData)
    }
    
    func observeFuturePrompts(member: CactusMember, since: Date=Date(), limit: Int?=nil, _ onData: @escaping (PageResult<SentPrompt>) -> Void) -> ListenerRegistration? {
        guard let memberId = member.id else {
            var result = PageResult<SentPrompt>()
            result.error = "No Member ID found on cactus member"
            onData(result)
            return nil
        }
        
        var query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .whereField(SentPrompt.Field.firstSentAt, isGreaterThan: Timestamp(date: since))
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        return self.firestoreService.addPaginatedListener(query, limit: limit, lastResult: nil, onData)
    }
    
    func getSentPrompts(member: CactusMember, limit: Int? = nil, before: DocumentSnapshot?=nil,  _ completed: @escaping ([SentPrompt]?, Any?) -> Void) {
        guard let memberId = member.id else {
            completed(nil, "No member ID found")
            return
        }
        
        var query = self.getCollectionRef()
            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
            .order(by: SentPrompt.Field.firstSentAt, descending: true)
            
        if let before = before {
            query = query.end(beforeDocument: before)
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        return self.firestoreService.executeQuery(query, { (sentPrompts, error) in
            completed(sentPrompts, error)
        })
    }
}
