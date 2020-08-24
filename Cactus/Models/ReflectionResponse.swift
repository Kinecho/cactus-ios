//
//  ReflectionResponse.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

class ReflectionResponseField: BaseModelField {
    static let question = "question"
    static let contentPath = "contentPath"
    static let sendDate = "sendDate"
    static let topic = "topic"
    static let userId = "userId"
    static let cactusMemberId = "cactusMemberId"
    static let responseDate = "responseDate"
    static let emailReplyId = "emailReplyId"
    static let responseMedium = "responseMedium"
    static let mailchimpMemberId = "mailchimpMemberId"
    static let mailchimpUniqueEmailId = "mailchimpUniqueEmailId"
    static let memberEmail = "memberEmail"
    static let content = "content"
    static let promptId = "promptId"
    static let promptQuestion = "promptQuestion"
    static let promptContentEntryId = "promptContentEntryId"
}

public enum ResponseMedium: String, Codable {
    case EMAIL
    case JOURNAL_WEB
    case JOURNAL_IOS
    case JOURNAL_ANDROID
    case PROMPT_WEB
    case PROMPT_IOS
    case PROMPT_ANDROID
}

struct ReflectionContent: Codable {
    var text: String?
}

typealias DynamicResponseValues = [String: String?]

class ReflectionResponse: FirestoreIdentifiable, Hashable {
    static let collectionName = FirestoreCollectionName.reflectionResponses
    static let Field = ReflectionResponseField.self
    var id: String?
    var deleted: Bool=false
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    var cactusMemberId: String?
    var responseDate: Date?
    var emailReplyId: String?
    var responseMedium: ResponseMedium?
    var mailchimpMemberId: String?
    var mailchimpUniqueEmailId: String?
    var memberEmail: String?
    var memberFirstName: String?
    var memberLastName: String?
    var content = ReflectionContent()
    var promptId: String?
    var promptQuestion: String?
    var promptContentEntryId: String?
    var reflectionDurationMs: Int?
    var cactusElement: CactusElement?
    var reflectionDates: [Date]?
    var shared: Bool? = false
    var sharedAt: Date?
    var unsharedAt: Date?
    var coreValue: String?
    var dynamicValues: DynamicResponseValues?
        
    var promptType: PromptType?
    var mightNeedInsightsUpdate: Bool? = false
    var insightsUpdatedAt: Date?
    
    var insights: InsightWordsResult?
    var toneAnalysis: ToneResult?
    var sentiment: SentimentResult?
    
    enum Key: CodingKey {
        case id
        case deleted
        case deletedAt
        case createdAt
        case updatedAt
        case userId
        case cactusMemberId
        case responseDate
        case emailReplyId
        case responseMedium
        case mailchimpMemberId
        case mailchimpUniqueEmailId
        case memberEmail
        case memberFirstName
        case memberLastName
        case content
        case promptId
        case promptQuestion
        case promptContentEntryId
        case reflectionDurationMs
        case cactusElement
        case reflectionDates
        case shared
        case sharedAt
        case unsharedAt
        case coreValue
        case dynamicValues
        case insights
        case toneAnalysis
        case sentiment
    }
    
    init() {}
    
    public required init(from decoder: Decoder) throws {
        let model = try ModelDecoder<Key>.create(decoder: decoder, codingKeys: Key.self)
        
        self.id = model.optionalString(.id)
        self.deleted = model.bool(.deleted, default: false)
        self.deletedAt = model.optDate(.deletedAt)
        self.createdAt = model.optDate(.createdAt)
        self.updatedAt = model.optDate(.updatedAt)
        self.userId = model.optionalString(.userId)
        self.cactusMemberId = model.optionalString(.cactusMemberId)
        self.responseDate = model.optDate(.responseDate)
        self.emailReplyId = model.optionalString(.emailReplyId)
        self.responseMedium = model.getOpt(.responseMedium, as: ResponseMedium.self)
        self.mailchimpMemberId = model.optionalString(.mailchimpMemberId)
        self.mailchimpUniqueEmailId = model.optionalString(.mailchimpUniqueEmailId)
        self.memberEmail = model.optionalString(.memberEmail)
        self.memberFirstName = model.optionalString(.memberFirstName)
        self.memberLastName = model.optionalString(.memberLastName)
        self.content = model.get(.content, as: ReflectionContent.self, default: ReflectionContent())
        self.promptId = model.optionalString(.promptId)
        self.promptQuestion = model.optionalString(.promptQuestion)
        self.promptContentEntryId = model.optionalString(.promptContentEntryId)
        self.reflectionDurationMs = model.optionalInt(.reflectionDurationMs)
        self.cactusElement = model.getOpt(.cactusElement, as: CactusElement.self)
        self.reflectionDates = model.getOpt(.reflectionDates, as: [Date].self)
        self.shared = model.optionalBool(.shared)
        self.sharedAt = model.optDate(.sharedAt)
        self.unsharedAt = model.optDate(.unsharedAt)
        self.coreValue = model.optionalString(.coreValue)
        self.dynamicValues = model.getOpt(.dynamicValues, as: DynamicResponseValues.self)
        
        self.insights = model.getOpt(.insights, as: InsightWordsResult.self)
        self.toneAnalysis = model.getOpt(.toneAnalysis, as: ToneResult.self)
        self.sentiment = model.getOpt(.sentiment, as: SentimentResult.self)
        
    }
    
    static func == (lhs: ReflectionResponse, rhs: ReflectionResponse) -> Bool {
        return lhs.id != nil && rhs.id != nil && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    /**
        Add a date to the reflection date array.
        - Parameter date: The date to add
        - Parameter thresholdInMinutes: The threshold to use to determine if a new date should be added to the array or not.
        - Returns: If the new date was added or not
     */
    func addReflectionLog(_ date: Date, thresholdInMinutes: Int = 10) -> Bool {
        if self.reflectionDates == nil {
            self.reflectionDates = []
        }
        
        let hasRecent = self.reflectionDates?.contains(where: { (d) -> Bool in
            return Int(abs(d.timeIntervalSince(date))) < (thresholdInMinutes * 60)
        })
        if hasRecent == true {
            return false
        }
        self.reflectionDates?.append(date)
        
        return true
    }
    
    /**
     Get the full name of the member that reflected. Uses the firstName and lastname when available.
     - Returns: String or nil. String value is trimmed of whitespaces
     */
    func getFullName() -> String? {
        let name = "\(self.memberFirstName ?? "") \(self.memberLastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        return FormatUtils.isBlank(name) ? nil : name
    }
    
    func getFullNameOrEmail() -> String? {
        let name = self.getFullName()
        if !FormatUtils.isBlank(name) {
            return name
        }
        return self.memberEmail
    }
    
    static func createFreeform(member: CactusMember) -> ReflectionResponse {
        let r = ReflectionResponse()
        r.cactusMemberId = member.id
        r.promptType = .FREE_FORM
        r.userId = member.userId        
        return r
    }
}

struct InsightWordsResult:Codable {
    var insightWords: [InsightWord] = []
}


enum ToneID: String, Codable, CaseIterable {
    case anger = "anger",
    fear = "fear",
    joy = "joy",
    sadness = "sadness",
    analytical = "analytical",
    confident = "confident",
    tentative = "tentative",
    unknown = "unknown"
}

struct ToneResult: Codable {
    struct ToneScore: Codable {
        var score: Double
        var toneId: ToneID
        var toneName: String
    }
    
    struct DocumentToneResult: Codable {
        var tones: [ToneScore]?
    }
    
    struct SentenceTone: Codable {
        var sentenceId: Int
        var text: String
        var tones: [ToneScore]?
    }
    
    var documentTone: DocumentToneResult?
    var sentencesTones: [SentenceTone]?
}

struct SentimentResult: Codable {
    struct SentimentSentence: Codable {
        var text: String?
        var sentiment: SentimentScore?
    }
    
    struct SentimentScore: Codable {
        /// A non-negative number in the [0, +inf) range, which represents the absolute magnitude of sentiment regardless of score (positive or negative).
        var magnitude: Double?
        /// Sentiment score between -1.0 (negative sentiment) and 1.0 (positive sentiment).
        var score: Double?
    }
    
    var sentences: [SentimentSentence]?
    var documentSentiment: SentimentScore?
    var language: String?
}
