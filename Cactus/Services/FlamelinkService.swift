//
//  FlamelinkService.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FlamelinkService {
    let firestoreService: FirestoreService
    
    static let sharedInstance = FlamelinkService()
    
    private init() {
        self.firestoreService = FirestoreService.sharedInstance
    }
    
    func getContentRef() -> CollectionReference {
        return self.firestoreService.getCollection(FirestoreCollectionName.fl_content)
    }
    
    func getContentQuery() -> Query {
        return self.getContentRef().whereField("_fl_meta_.env", isEqualTo: CactusConfig.flamelink.environmentId)
    }
    
//    func observeSentPrompts(member: CactusMember, _ onData: @escaping ([SentPrompt]?, Any?) -> Void) -> ListenerRegistration? {
//        guard let memberId = member.id else {
//            onData(nil, "No member ID found")
//            return nil
//        }
//
//        let query = self.getCollectionRef()
//            .whereField(SentPrompt.Field.cactusMemberId, isEqualTo: memberId)
//            .order(by: SentPrompt.Field.firstSentAt, descending: true)
//
//        return self.firestoreService.addListener(query, { (sentPrompts, error) in
//            onData(sentPrompts, error)
//        })
//    }
    
    func getQuery(_ schema: FlamelinkSchema) -> Query {
        return getContentQuery().whereField("_fl_meta_.schema", isEqualTo: schema.rawValue)
    }
    
    
    
    
    
    func getEntryIdQuery(_ id: String, schema: FlamelinkSchema) -> Query {
        return getQuery(schema).whereField("_fl_meta_.fl_id", isEqualTo: id)
    }
    
    func getByEntryId<T: FlamelinkIdentifiable>(_ id: String, schema: FlamelinkSchema, _ onData: @escaping (_ object: T?, _ error: Any?) -> Void) {
        let query = getEntryIdQuery(id, schema: schema)
        
        query.getDocuments { docs, error in
            guard let doc = docs?.documents.first else {
                return onData(nil, error)
            }
            let data = doc.data()
            print("data is \(data)")
            let object = try? doc.decode(as: T.self, includingId: false)
            onData(object, error)
        }
    }
}
