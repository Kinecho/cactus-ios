//
//  SentPromptService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
//
//  CactusMemberService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore
class SentPromptService {
    
    let firestoreService: FirestoreService
    
    static let sharedInstance = SentPromptService();
    
    private init(){
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
        
        let query = self.getCollectionRef().whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
        return self.firestoreService.addListener(query, { (sentPrompts, error) in
            onData(sentPrompts, error)
        })
    }
    
    func getById(id:String) {
        
    }
}
