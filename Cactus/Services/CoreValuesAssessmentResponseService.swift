//
//  CoreValuesAssessmentResponseService.swift
//  Cactus
//
//  Created by Neil Poulin on 4/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class CoreValuesAssessmentResponseService {
    let firestoreService: FirestoreService
    
    public static var shared = CoreValuesAssessmentResponseService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.coreValuesAssessmentResponses)
    }
    
    func latestResponse(_ completed: @escaping (CoreValuesAssessmentResponse?, Any?) -> Void) {
        guard let member = CactusMemberService.sharedInstance.currentMember, let memberId = member.id else {
            completed(nil, "No member was found")
            return
        }
        let query = self.getCollectionRef().whereField(CoreValuesAssessmentResponse.Field.completed, isEqualTo: true)
            .whereField(BaseModelField.deleted, isEqualTo: false)
            .whereField(CoreValuesAssessmentResponse.Field.memberId, isEqualTo: memberId)
            .order(by: CoreValuesAssessmentResponse.Field.createdAt, descending: true)
        self.firestoreService.getFirst(query, completed)
    }
    
    func observeLatestResponse(_ completed: @escaping (CoreValuesAssessmentResponse?, Any?) -> Void) -> ListenerRegistration? {
        guard let member = CactusMemberService.sharedInstance.currentMember, let memberId = member.id else {
            completed(nil, "No member was found")
            return nil
        }
        let query = self.getCollectionRef().whereField(CoreValuesAssessmentResponse.Field.completed, isEqualTo: true)
            .whereField(BaseModelField.deleted, isEqualTo: false)
            .whereField(CoreValuesAssessmentResponse.Field.memberId, isEqualTo: memberId)
            .order(by: CoreValuesAssessmentResponse.Field.createdAt, descending: true)
        return self.firestoreService.observeFirst(query, completed)
    }
    
}
