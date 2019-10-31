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
    
    func getQuery(_ schema: FlamelinkSchema) -> Query {
        return getContentQuery().whereField("_fl_meta_.schema", isEqualTo: schema.rawValue)
    }
    
    func getEntryIdQuery(_ id: String, schema: FlamelinkSchema) -> Query {
        return getQuery(schema).whereField("_fl_meta_.fl_id", isEqualTo: id)
    }
    
    func executeQuery<T: FlamelinkIdentifiable>(_ query: Query, _ onData: @escaping (_ models: [T]?, _ error: Any?) -> Void) {
        query.getDocuments { snapshot, error in
            if let error = error {
                return onData(nil, error)
            }
            var models: [T] = []
            snapshot?.documents.forEach({ (doc) in
                if let model = try? doc.decode(as: T.self, includingId: false) {
                    models.append(model)
                }
            })
            
            onData(models, error)
        }
    }
    
    func observeQuery<T: FlamelinkIdentifiable>(_ query: Query, _ onData: @escaping (_ models: [T]?, _ error: Any?) -> Void) -> ListenerRegistration {
        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                return onData(nil, error)
            }
            var models: [T] = []
            snapshot?.documents.forEach({ (doc) in
                if let model = try? doc.decode(as: T.self, includingId: false) {
                    models.append(model)
                }
            })
            
            onData(models, error)
        }
    }
    
    func getFirst<T: FlamelinkIdentifiable>(_ query: Query, _ onData: @escaping (_ object: T?, _ error: Any?) -> Void) {
        query.getDocuments { docs, error in
            guard let doc = docs?.documents.first else {
                return onData(nil, error)
            }
            let object = try? doc.decode(as: T.self, includingId: false)
            onData(object, error)
        }
    }
    
    func getByEntryId<T: FlamelinkIdentifiable>(_ id: String, schema: FlamelinkSchema, _ onData: @escaping (_ object: T?, _ error: Any?) -> Void) {
        let query = getEntryIdQuery(id, schema: schema)
        self.getFirst(query, onData)
//        query.getDocuments { docs, error in
//            guard let doc = docs?.documents.first else {
//                return onData(nil, error)
//            }
//            let object = try? doc.decode(as: T.self, includingId: false)
//            onData(object, error)
//        }
    }
    
    func observeByEntryId<T: FlamelinkIdentifiable>(_ id: String, _ onData: @escaping (T?, Any?) -> Void) -> ListenerRegistration {
        let query = getQuery(T.self.schema)
        return query.whereField("_fl_meta_.fl_id", isEqualTo: id).addSnapshotListener({ (snapshot, error) in
            let model = try? snapshot?.documents.first?.decode(as: T.self)
            onData(model, error)
        })
    }
    
    func addListener<T: FlamelinkIdentifiable>(_ query: Query, _ onData: @escaping ([T]?, Any?) -> Void) -> ListenerRegistration {
        // let query = query.whereField(BaseModelField.deleted, isEqualTo: false)
        // NOTE: For straight up firstore queries, we append a "deleted" filter. For Flamelink we do not.
        let listener = query.addSnapshotListener(self.snapshotListener(onData))
        
        return listener
    }
    
    private func snapshotListener<T: FlamelinkIdentifiable>( _ onData: @escaping ([T]?, Any?) -> Void) -> FIRQuerySnapshotBlock {
        func handler (_ snapshot: QuerySnapshot?, _ error: Error?) {
            if let error = error {
                return onData(nil, error)
            }
            guard let documents = snapshot?.documents else {
                return onData(nil, "Unable to get documents")
            }
            var results = [T]()
            documents.forEach({ (document) in
                do {
                    let object = try document.decode(as: T.self, includingId: false)
                    results.append(object)
                } catch {
                    print("error decodding document", error)
                }
            })
            return onData(results, nil)
        }
        
        return handler
    }
    
}
