//
//  PromptContent.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

enum ContentType: String, Codable {
    case text
    case quote
    case video
    case photo
    case audio
    case reflect
    case share_reflection
    case elements
    case unknown
    public init(from decoder: Decoder) {
        do {
            self = try ContentType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        } catch {
            self = .unknown
        }
    }
}

enum ContentAction: String, Codable {
    case next
    case previous
    case complete
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try ContentAction(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum LinkTarget: String, Codable {
    case _blank
    case _self
    case _parent
    case _top
    
    public init(from decoder: Decoder) throws {
        self = try LinkTarget(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? ._blank
    }
}

enum LinkStyle: String, Codable {
    case buttonPrimary
    case buttonSecondary
    case fancyLink
    case link
    
    public init(from decoder: Decoder) throws {
        self = try LinkStyle(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .link
    }
}

class Quote: Codable {
    var text: String?
    var authorName: String?
    var authorTitle: String?
    var authorAvatar: ImageFile?
}

class ContentLink: Codable {
    var linkLabel: String?
    var destinationHref: String?
    var linkTarget: LinkTarget?
    var linkStyle: LinkStyle?
    
}

class ActionButton: Codable {
    var action: ContentAction
    var label: String
}

enum ImagePosition: String, Codable {
    case top
    case bottom
    case center
}

class ContentBackgroundImage: ImageFile {
    var position: ImagePosition?
}

class Content: Codable {
    var contentType: ContentType
    var quote: Quote?
    var text: String?
    var text_md: String?
    var backgroundImage: ContentBackgroundImage?
    var label: String?
    var title: String?
    var video: VideoFile?
    var photo: ImageFile?
    var audio: AudioFile?
    var link: ContentLink?
    var actionButton: ActionButton?
    var showElementIcon: Bool?
}

class PromptContent: FlamelinkIdentifiable {
    static var schema = FlamelinkSchema.promptContent
    var _fl_meta_: FlamelinkMeta?
    var documentId: String?
    var entryId: String?
    var order: Int?
    var content: [Content] = []
    
    var promptId: String?
    var subjectLine: String?
    var topic: String?
    var shareReflectionCopy_md: String?
    var cactusElement: CactusElement?
    
    enum CodingKeys: String, CodingKey {
        case _fl_meta_
        case documentId
        case entryId
        case order
        case content
        case promptId
        case subjectLine
        case topic
        case shareReflectionCopy_md
        case cactusElement
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self._fl_meta_ = try? values.decode(FlamelinkMeta.self, forKey: ._fl_meta_)
        self.documentId = try? values.decode(String.self, forKey: .documentId)
        self.entryId = self._fl_meta_?.fl_id
        self.order = try? values.decode(Int.self, forKey: .order)
        self.content = (try? values.decode([Content].self, forKey: .content)) ?? []
        self.promptId = try? values.decode(String.self, forKey: .promptId)
        self.subjectLine = try? values.decode(String.self, forKey: .subjectLine)
        self.topic = try? values.decode(String.self, forKey: .topic)
        self.shareReflectionCopy_md = try? values.decode(String.self, forKey: .shareReflectionCopy_md)
        self.cactusElement = try? values.decode(CactusElement.self, forKey: .cactusElement)
    }
    
    func getQuestion() -> String? {
        self.content.first {$0.contentType == .reflect}?.text
    }
    
    func getQuestionMarkdown() -> String? {
        let content = self.content.first {$0.contentType == .reflect}
        return FormatUtils.isBlank(content?.text_md) ? content?.text : content?.text_md
    }
}
