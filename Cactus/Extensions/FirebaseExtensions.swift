//
//  FirebaseExtensions.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Foundation
import CodableFirebase

enum EncodableExtensionError: Error {
    case encodingError
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

//extension Encodable {
extension FirestoreIdentifiable {

    /**
     Serialize An Encodable object to JSON. By default it will ignore the ID String
     */
    func toFirestoreData(excluding excludedKeys: [String] = ["id"] ) throws -> [String: Any] {
        
        let encoder = FirestoreEncoder()
        
        var docData = try encoder.encode(self)
        
        for key in excludedKeys {
            docData.removeValue(forKey: key)
        }
        
        return docData
    }
}

extension FlamelinkIdentifiable {
    func toFlamelinkeData(excluding excludedKeys: [String] = ["entryId", "schema"] ) throws -> [String: Any] {
        
        let encoder = FirestoreEncoder()
        
        var docData = try encoder.encode(self)
        
        for key in excludedKeys {
            docData.removeValue(forKey: key)
        }
        
        return docData
    }
}

enum DocumentSnapshotExtensionError: Error {
    case decodingError
}

extension DocumentSnapshot {
    func convertTimestamp(_ value: Any) -> Any {
        var changed = value
        switch value {
        case _ as DocumentReference:
            break
        case let ts as Timestamp: //convert timestamp to date value
            let date = ts.dateValue()
            let jsonValue = Int((date.timeIntervalSince1970 * 1000).rounded())
            changed = jsonValue
        default:
            break
        }
        return changed
    }
    
    func transformValue(_ value: Any) -> Any {
        switch value {
        case let array as [Any]:
            let values = array.map(transformValue)
            return values
        case let map as [String: Any]:
            return transformJson(map)
        default:
            return convertTimestamp(value)
        }
    }
    
    func transformJson(_ documentJson: [String: Any] ) -> [String: Any] {
        var documentJson = documentJson
        documentJson.forEach { (key: String, value: Any) in
            switch value {
            case _ as DocumentReference:
                documentJson.removeValue(forKey: key)
            default:
                documentJson[key] = transformValue(value)
            }
            
        }
        return documentJson
    }
    
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws -> T {
        do {
            
            guard var documentData = self.data() else {throw DocumentSnapshotExtensionError.decodingError}
            if includingId {
                documentData["id"] = self.documentID
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
            
            documentData = transformJson(documentData)
            
            let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            
            let decodedObject = try decoder.decode(objectType, from: jsonData)
            return decodedObject
        } catch {
            Logger.shared.error("failed to decode", error, fileName: "FirebaseExtensions", functionName: #function)
            throw error
        }
        
    }
}
