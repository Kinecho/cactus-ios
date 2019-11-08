//
//  FirestoreService.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Foundation
import CodableFirebase

typealias Unsubscriber = () -> Void

struct PageResult<T: FirestoreIdentifiable> {
    var error: Any?
    var results: [T]?
    var firstSnapshot: DocumentSnapshot?
    var lastSnapshot: DocumentSnapshot?
    var mightHaveMore: Bool = false
    var pageSize: Int?
}

class FirestoreService {
    let db: Firestore
    
    static let sharedInstance = FirestoreService()
    
    private init() {
        let firestoreSettings = FirestoreSettings()
        firestoreSettings.isPersistenceEnabled = true
        self.db = Firestore.firestore()
    }
    
    func getFirst<T: FirestoreIdentifiable>(_ query: Query, _ onData: @escaping (T?, Any?) -> Void) {
        query.getDocuments { docs, error in
            guard let doc = docs?.documents.first else {
                return onData(nil, error)
            }
            
            let object = try? doc.decode(as: T.self)
            onData(object, error)
        }
        
    }
    
    func observeById<T: FirestoreIdentifiable>(_ id: String, _ onData: @escaping (T?, Any?) -> Void) -> ListenerRegistration {
        let collection = getCollection(T.self.collectionName)
        return collection.document(id).addSnapshotListener({ (snapshot, error) in
            let model = try? snapshot?.decode(as: T.self)
            if let deleted = model?.deleted, deleted {
                onData(nil, error)                
            } else {
                onData(model, error)
            }
        })
    }
    
    func executeQuery<T: FirestoreIdentifiable>(_ query: Query, _ onData: @escaping ([T]?, Any?) -> Void) {
        query.whereField(BaseModelField.deleted, isEqualTo: false).getDocuments(completion: self.snapshotListener(onData))
    }
    
    func addListener<T: FirestoreIdentifiable>(_ query: Query, _ onData: @escaping ([T]?, Any?) -> Void) -> ListenerRegistration {
        let query = query.whereField(BaseModelField.deleted, isEqualTo: false)        
        
        let listener = query.addSnapshotListener(self.snapshotListener(onData))
        
        return listener
    }
    
    func addPaginatedListener<T: FirestoreIdentifiable>(_ query: Query, limit: Int?=nil, lastResult: PageResult<T>?, _ onData: @escaping (PageResult<T>) -> Void) -> ListenerRegistration {
        var query = query.whereField(BaseModelField.deleted, isEqualTo: false)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        if let after = lastResult?.lastSnapshot {
            query = query.start(afterDocument: after)
        }
        
        let listener = query.addSnapshotListener(self.paginatedSnapshotListener(onData, limit: limit))
        
        return listener
    }
    
    private func paginatedSnapshotListener<T: FirestoreIdentifiable>( _ onData: @escaping (PageResult<T>) -> Void, limit: Int?=nil) -> FIRQuerySnapshotBlock {
        func handler (_ snapshot: QuerySnapshot?, _ error: Error?) {
            var result = PageResult<T>()
            if let error = error {
                result.error = error
                return onData(result)
            }
            guard let documents = snapshot?.documents else {
                result.error = "Unable to fetch documents"
                return onData(result)
            }
            var models = [T]()
            documents.forEach({ (document) in
                do {
                    let object = try document.decode(as: T.self)
                    models.append(object)
                } catch {
                    print("error decodding document", error)
                }
            })
            
            result.results = models
            result.firstSnapshot = documents.first
            result.lastSnapshot = documents.last
            
            if let limit = limit {
                result.pageSize = limit
                result.mightHaveMore = documents.count == limit
            }
            
            return onData(result)
        }
        
        return handler
    }
    
    private func snapshotListener<T: FirestoreIdentifiable>( _ onData: @escaping ([T]?, Any?) -> Void) -> FIRQuerySnapshotBlock {
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
                    let object = try document.decode(as: T.self)
                    results.append(object)
                } catch {
                    print("error decodding document", error)
                }
            })
            return onData(results, nil)
        }
        
        return handler
    }
    
    func save<T: FirestoreIdentifiable>(_ object: T, onComplete: @escaping (_ savedObject: T?, _ error: Any? ) -> Void) {
        var object = object
        let ref = getDocumentRef(object)
        let currentUserId = AuthService.sharedInstance.getCurrentUser()?.uid
        
        if var ownable = object as? FirestoreOwnable {
            if ownable.id == nil && ownable.createdByUserId == nil {
                ownable.createdByUserId = currentUserId
            }
            ownable.updatedByUserId = currentUserId
            if let obj = ownable as? T {
                object = obj
            }
        }
        var isNew = false
        if object.id == nil {
            object.createdAt = Date()
            isNew = true
        }
        object.updatedAt = Date()
        
        do {
            let json = try object.toFirestoreData() //note: this ignores the ID string by default            
            ref.setData(json, merge: true) { (error) in
                var savedObject = object
                savedObject.id = ref.documentID
                print("Saved Document. IsNew = \(isNew)")
                
                if let error = error {
                    print("Failed to save document", error)
                }
                onComplete(savedObject, error)
            }
        } catch {
            print("ERROR SAVING \(error)")
            onComplete(nil, error)
        }
    }
    
    func getById<T: FirestoreIdentifiable>(_ id: String, from collectionName: FirestoreCollectionName, completion: @escaping (_ object: T?, _ error: Any?) -> Void) {
        guard let ref = getDocumentRef(id, in: collectionName) else {return completion(nil, "Unable to get document ref")}
        
        ref.getDocument { (documemntSnapshot, error) in
            if let error = error {
                return completion(nil, error)
            }
            do {
                let object = try documemntSnapshot?.decode(as: T.self)
                return completion(object, nil)
            } catch {
                print("error decoding object", error)
                return completion(nil, error)
            }
        }
    }
    
    func delete<T: FirestoreIdentifiable>(_ object: T, onComplete: @escaping (_ error: Any?) -> Void) {
        let ref = getDocumentRef(object)
        ref.updateData([
            BaseModelField.deleted: true,
            BaseModelField.deletedAt: Timestamp()
        ]) { err in
            if let err = err {
                print("Failed to delete document", err)
            }
            onComplete(err)
        }
    }
    
    /*
     Delete via query
     */
    func delete(from collectionName: FirestoreCollectionName, where fieldName: String, isEqualTo: Any, completion: @escaping (Int?, Any?) -> Void ) {
        let collection = getCollection(collectionName)
        let query = collection.whereField(fieldName, isEqualTo: isEqualTo)
        let batch = db.batch()
        var deletedCount = 0
        query.getDocuments { snapshot, _ in
            snapshot?.documents.forEach({ (doc) in
                batch.updateData([
                    BaseModelField.deleted: true,
                    BaseModelField.deletedAt: Timestamp()
                    ], forDocument: doc.reference)
                deletedCount += 1
                
            })
            
            batch.commit { err in
                if let err = err {
                    print("failed to delete documents", err)
                    return completion(nil, err)
                } else {
                    print("deleted batch successfully")
                    return completion(deletedCount, nil)
                }
            }
        }
        
    }
    
    func getCollection<T: FirestoreIdentifiable>(_ obj: T) -> CollectionReference {
        return getCollection(type(of: obj).collectionName)
    }
    
    func getCollection(_ name: FirestoreCollectionName) -> CollectionReference {
        return db.collection(name.rawValue)
    }
    
    func getDocumentRef(_ id: String?, in collectionName: FirestoreCollectionName) -> DocumentReference? {
        guard let id = id else {return nil}
        
        return getCollection(collectionName).document(id)
    }
    
    func getDocumentRef<T: FirestoreIdentifiable>(_ obj: T) -> DocumentReference {
        let collection = getCollection(obj)
        
        if let id = obj.id {
            return collection.document(id)
        } else {
            return collection.document()
        }
    }
    
}
