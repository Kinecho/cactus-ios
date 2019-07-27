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

class FirestoreService {
    let db: Firestore;
    
    static let sharedInstance = FirestoreService();
    
    private init(){
        let firestoreSettings = FirestoreSettings();
        firestoreSettings.isPersistenceEnabled = true;
        self.db = Firestore.firestore();
    }
    
    func getFirst<T:FirestoreIdentifiable>(_ query: Query, _ onData: @escaping (T?, Any?) -> Void) -> Void{
        query.getDocuments { docs, error in
            guard let doc = docs?.documents.first else {
                return onData(nil, error)
            }
            
            let object = try? doc.decode(as: T.self)
            onData(object, error)
        }
        
    }
    
    func observeById<T:FirestoreIdentifiable>(_ id: String, _ onData: @escaping (T? , Any?) -> Void) -> ListenerRegistration {
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
    
    func getDocuments<T:FirestoreIdentifiable>(_ query: Query, _ onData: @escaping ([T]?, Any?) -> Void) -> Void{
        query.whereField(BaseModelField.deleted, isEqualTo: false).getDocuments(completion: self.snapshotListener(onData))
    }
    
    func addListener<T:FirestoreIdentifiable>(_ query: Query, _ onData: @escaping ([T]?, Any?) -> Void) -> ListenerRegistration{
        let query = query.whereField(BaseModelField.deleted, isEqualTo: false)        
        
        let listener = query.addSnapshotListener(self.snapshotListener(onData))
        
        return listener
    }
    
    private func snapshotListener<T:FirestoreIdentifiable>( _ onData: @escaping ([T]?, Any?) -> Void) -> FIRQuerySnapshotBlock{
        func handler (_ snapshot: QuerySnapshot?, _ error: Error?) {
            if let error = error {
                return onData(nil, error)
            }
            guard let documents = snapshot?.documents else  {
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
            object = ownable as! T
        }
        var isNew = false
        if (object.id == nil){
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
    
    func getById<T:FirestoreIdentifiable>(_ id: String, from collectionName: FirestoreCollectionName, completion: @escaping (_ object: T?, _ error: Any?) -> Void) -> Void {
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
    
    func delete<T:FirestoreIdentifiable>(_ object: T, onComplete: @escaping (_ error: Any?) -> Void) {
        let ref = getDocumentRef(object)
        ref.updateData([
            BaseModelField.deleted: true,
            BaseModelField.deletedAt: Timestamp()
        ]){ err in
            if let err = err {
                print("Failed to delete document", err)
            }
            onComplete(err)
        }
    }
    
    /*
     Delete via query
     */
    func delete(from collectionName: FirestoreCollectionName, where fieldName: String, isEqualTo: Any, completion: @escaping (Int?, Any?) -> Void ){
        let collection = getCollection(collectionName)
        let query = collection.whereField(fieldName, isEqualTo: isEqualTo)
        let batch = db.batch()
        var deletedCount = 0
        query.getDocuments(){ snapshot, error in
            snapshot?.documents.forEach({ (doc) in
                batch.updateData([
                    BaseModelField.deleted: true,
                    BaseModelField.deletedAt: Timestamp()
                    ], forDocument: doc.reference)
                deletedCount += 1
                
            })
            
            batch.commit(){ err in
                if let err = err {
                    print("failed to delete documents", err)
                    return completion(nil, err)
                }
                else {
                    print("deleted batch successfully")
                    return completion(deletedCount, nil)
                }
            }
        }
        
    }
    
    
    
    func getCollection<T: FirestoreIdentifiable>(_ obj: T) -> CollectionReference{
        return getCollection(type(of: obj).collectionName)
    }
    
    func getCollection(_ name: FirestoreCollectionName) -> CollectionReference {
        return db.collection(name.rawValue)
    }
    
    func getDocumentRef(_ id: String?, in collectionName: FirestoreCollectionName) -> DocumentReference? {
        guard let id = id else {return nil}
        
        return getCollection(collectionName).document(id)
    }
    
    func getDocumentRef<T:FirestoreIdentifiable>(_ obj: T) -> DocumentReference {
        let collection = getCollection(obj)
        
        if let id = obj.id {
            return collection.document(id)
        }
        else {
            return collection.document()
        }
    }
    
}


enum EncodableExtensionError:Error {
    case encodingError
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

extension Encodable {
    
    /**
     Serialize An Encodable object to JSON. By default it will ignore the ID String
     */
    func toFirestoreData(excluding excludedKeys: [String] = ["id"] ) throws -> [String: Any] {
        
        let encoder = FirestoreEncoder()
        
        var docData = try! encoder.encode(self)
        
        for key in excludedKeys {
            docData.removeValue(forKey: key)
        }
        
        return docData
    }
}

enum DocumentSnapshotExtensionError:Error {
    case decodingError
}


extension DocumentSnapshot {
    func convertTimestamp(_ value:Any) -> Any {
        var changed = value
        switch value{
        case _ as DocumentReference:
            break
        case let ts as Timestamp: //convert timestamp to date value
            let date = ts.dateValue()
            let jsonValue = Int((date.timeIntervalSince1970 * 1000).rounded())
            changed = jsonValue
            break
        default:
            break
        }
        return changed
    }
    
    func transformValue(_ value: Any) -> Any {
        if value is Array<Any>
        {
            let values = (value as! Array).map(transformValue)
            return values
        }
        else if value is [String: Any] {
            return transformJson(value as! [String: Any])
        } else {
            return convertTimestamp(value)
        }
    }
    
    func transformJson(_ documentJson:[String: Any] ) -> [String: Any]{
        var documentJson = documentJson
        documentJson.forEach { (key: String, value: Any) in            
            switch value{
            case _ as DocumentReference:
                documentJson.removeValue(forKey: key)
                break
            default:
                documentJson[key] = transformValue(value);
                break
            }
            
        }
        
        return documentJson
    }

    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws -> T {
        do {
            guard var documentJson = self.data() else {throw DocumentSnapshotExtensionError.decodingError}
            if includingId {
                documentJson["id"] = self.documentID
            }
            
            //transform any values in the data object as needed
//            documentJson.forEach { (key: String, value: Any) in
//                switch value{
//                case _ as DocumentReference:
//                    documentJson.removeValue(forKey: key)
//                    break
//                case let ts as Timestamp: //convert timestamp to date value
//                    let date = ts.dateValue()
//                    let jsonValue = Int((date.timeIntervalSince1970 * 1000).rounded())
//                    documentJson[key] = jsonValue
//
//                    break
//                default:
//                    break
//                }
//            }

            documentJson = transformJson(documentJson)
            
            let documentData = try JSONSerialization.data(withJSONObject: documentJson, options: [])
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            
            let decodedObject = try decoder.decode(objectType, from: documentData)
            return decodedObject
        } catch {
            print("failed to decode", error)
            throw error
        }
        
    }
}
