//
//  ReflectionResponseService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ReflectionResponseService {
    let firestoreService: FirestoreService
    let logger = Logger("ReflectionResponseService")
    static let sharedInstance = ReflectionResponseService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getCollectionRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.reflectionResponses)
    }
    
    func observeById(id: String, _ onData: @escaping (ReflectionResponse?, Any?) -> Void) -> ListenerRegistration? {
        return self.firestoreService.observeById(id, onData)
    }
    
    func getForPromptId(promptId: String, _ onData: @escaping ([ReflectionResponse]?, Any?) -> Void) {
        guard let currentMember = CactusMemberService.sharedInstance.getCurrentMember(), let memberId = currentMember.id else {
            onData([], nil)
            return
        }
        let query = self.getCollectionRef().whereField(ReflectionResponse.Field.cactusMemberId, isEqualTo: memberId).whereField(ReflectionResponseField.promptId, isEqualTo: promptId)
        self.firestoreService.executeQuery(query, onData)
    }
    
    func observeForPromptId(id: String, _ onData: @escaping ([ReflectionResponse]?, Any?) -> Void) -> ListenerRegistration? {
        guard let currentMember = CactusMemberService.sharedInstance.getCurrentMember(), let memberId = currentMember.id else {
            onData([], "No cactus member")
            return nil
        }
        let query = self.getCollectionRef().whereField(ReflectionResponse.Field.cactusMemberId, isEqualTo: memberId).whereField(ReflectionResponseField.promptId, isEqualTo: id)
    
        return self.firestoreService.addListener(query, onData)
        
    }
    
    func save(_ response: ReflectionResponse, addReflectionLog: Bool=true, _ onData: @escaping (ReflectionResponse?, Any?) -> Void) {
        if addReflectionLog {
            _ = response.addReflectionLog(Date())
        }
        self.firestoreService.save(response, onComplete: onData)
    }
    
    func delete(_ response: ReflectionResponse, _ onData: @escaping (_ error: Any?) -> Void) {
        self.firestoreService.delete(response, onComplete: onData)
    }
    
    func createReflectionResponse(_ prompt: ReflectionPrompt, medium: ResponseMedium = .JOURNAL_IOS) -> ReflectionResponse {
        let response = ReflectionResponse()
        response.promptId = prompt.id
        response.promptQuestion = prompt.question
        
        response.responseMedium = medium
        if let member = CactusMemberService.sharedInstance.currentMember {
            response.cactusMemberId = member.id
            response.userId = member.userId
            response.memberEmail = member.email
            if let listMember = member.mailchimpListMember {
                response.mailchimpMemberId = listMember.id
                response.mailchimpUniqueEmailId = listMember.unique_email_id
            }
        } else {
            self.logger.warn("Warning: no cactus member was found", functionName: #function, line: #line)
        }
        
        return response
    }
    
    func createReflectionResponse(_ promptId: String, promptQuestion: String?, element: CactusElement?, medium: ResponseMedium) -> ReflectionResponse? {
        guard let member = CactusMemberService.sharedInstance.currentMember else {
            return nil
        }
        
        let response = ReflectionResponse()
        response.promptId = promptId
        response.cactusMemberId = member.id
        response.promptQuestion = promptQuestion
        response.userId = member.userId
        response.memberEmail = member.email
        response.responseMedium = medium
        response.cactusElement = element
        if let listMember = member.mailchimpListMember {
            response.mailchimpMemberId = listMember.id
            response.mailchimpUniqueEmailId = listMember.unique_email_id
        }
        
        return response
    }
    
    func shareReflection(_ response: ReflectionResponse, _ completed: @escaping (ReflectionResponse?, Any?) -> Void) {
        response.shared = true
        response.sharedAt = Date()
        if let member = CactusMemberService.sharedInstance.currentMember {
            response.memberFirstName = member.firstName
            response.memberLastName = member.lastName
        }
        
        self.save(response, completed)
    }
    
    func getById(_ responseId: String, _ completed: @escaping (ReflectionResponse?, Any?) -> Void) {
        self.firestoreService.getById(responseId, from: FirestoreCollectionName.reflectionResponses, completion: completed)
    }
}
