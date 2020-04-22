//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 4/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

typealias CoreValue = String

public class CoreValuesAssessmentResponseField: BaseModelField {
    static public let email = "membereId"
    static public let completed = "completed"
    static public let memberId = "memberId"
}

class CoreValuesQuestionResponse: Codable {
    var questionId: String!
    var values: [CoreValue] = []
}

class CoreValuesResults: Codable {
    var values: [CoreValue] = []
}

class CoreValuesAssessmentResponse: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.coreValuesAssessmentResponses
    static let Field = CoreValuesAssessmentResponseField.self
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    var completed: Bool = false
    var assessmentVersion: String = "v1"
    var questionResponses: [String: CoreValuesQuestionResponse] = [:]
    var results: CoreValuesResults?
    
    enum AssessmentResponseCodingKey: CodingKey {
        case id
        case deleted
        case deletedAt
        case createdAt
        case updatedAt
        case completed
        case assessmentVersion
        case questionRespones
        case results
    }
    
    //    public required init(from decoder: Decoder) throws {
    //        guard let model = ModelDecoder<AssessmentResponseCodingKey>.create(decoder: decoder, codingKeys: AssessmentResponseCodingKey.self) else {
    //            return
    //        }
    //
    //
    //        self.text = model.optionalString(.text, blankAsNil: true)
    //        self.authorName = model.optionalString(.authorName, blankAsNil: true)
    //        self.authorTitle = model.optionalString(.authorTitle, blankAsNil: true)
    //        self.text_md = model.optionalString(.text_md, blankAsNil: true)
    //
    //        if (try? model.container.decode(String.self, forKey: .authorAvatar)) == nil {
    //            self.authorAvatar = try? model.container.decode(ImageFile.self, forKey: .authorAvatar)
    //        }
    //    }
    
    static func == (lhs: CoreValuesAssessmentResponse, rhs: CoreValuesAssessmentResponse) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
