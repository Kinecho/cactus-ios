//
//  PromptContent.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

enum ContentStatus: String, Codable {
    case in_progress
    case submitted
    case processing
    case needs_changes
    case published
    case unknown
    
    public init(from decoder: Decoder) {
        do {
            self = try ContentStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        } catch {
            self = .unknown
        }
    }
}

enum ContentType: String, Codable {
    case text
    case quote
    case video
    case photo
    case audio
    case reflect
    case share_reflection
    case elements
    case invite    
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
    
    var isEmpty: Bool {
        isBlank(text) && isBlank(authorName) && isBlank(authorTitle) && (authorAvatar?.isEmpty ?? true)
    }
    
    enum QuoteCodingKey: CodingKey {
        case text
        case authorName
        case authorTitle
        case authorAvatar
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: QuoteCodingKey.self)
            self.text = try? container.decode(String.self, forKey: .text)
            self.authorName = try? container.decode(String.self, forKey: .authorName)
            self.authorTitle = try? container.decode(String.self, forKey: .authorTitle)
            if (try? container.decode(String.self, forKey: .authorAvatar)) == nil {
                self.authorAvatar = try? container.decode(ImageFile.self, forKey: .authorAvatar)
            }
        } catch {
//            Logger.shared.error("error decoding Quote content", error)
        }
    }
    
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
    
    enum ContentCodingKeys: CodingKey {
        case contentType
        case quote
        case text
        case text_md
        case backgroundImage
        case label
        case title
        case video
        case photo
        case audio
        case link
        case actionButton
        case showElementIcon
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: ContentCodingKeys.self)
            self.contentType = (try? container.decode(ContentType.self, forKey: ContentCodingKeys.contentType)) ?? ContentType.text
            self.quote = try? container.decode(Quote.self, forKey: ContentCodingKeys.quote)
            if self.quote?.isEmpty == true {
                self.quote = nil
            }
            
            self.text = try? container.decode(String.self, forKey: ContentCodingKeys.text)
            self.text_md = try? container.decode(String.self, forKey: ContentCodingKeys.text_md)
            self.backgroundImage = try? container.decode(ContentBackgroundImage.self, forKey: ContentCodingKeys.backgroundImage)
            self.label = try? container.decode(String.self, forKey: ContentCodingKeys.label)
            self.title = try? container.decode(String.self, forKey: ContentCodingKeys.title)
            
            self.video = try? container.decode(VideoFile.self, forKey: ContentCodingKeys.video)
            if video?.isEmpty == true {
                self.video = nil
            }
            
            self.photo = try? container.decode(ImageFile.self, forKey: ContentCodingKeys.photo)
            if self.photo?.isEmpty == true {
                self.photo = nil
            }
            
            self.audio = try? container.decode(AudioFile.self, forKey: ContentCodingKeys.audio)
            self.link = try? container.decode(ContentLink.self, forKey: ContentCodingKeys.link)
            self.actionButton = try? container.decode(ActionButton.self, forKey: ContentCodingKeys.actionButton)
            self.showElementIcon = try? container.decode(Bool.self, forKey: ContentCodingKeys.showElementIcon)
        } catch {
            self.contentType = ContentType.text
            Logger.shared.error("error decoding ImageFile", error)
        }
    }
}

struct PromptContentField {
    static let scheduledSendAt = "scheduledSendAt"
    static let entryId = "entryId"
    static let promptId = "promptId"
    static let contentStatus = "contentStatus"
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
    var contentStatus: ContentStatus = .unknown
    
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
        case contentStatus
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
        self.contentStatus = (try? values.decode(ContentStatus.self, forKey: .contentStatus)) ?? .unknown
    }
    
    func getQuestion() -> String? {
        self.content.first {$0.contentType == .reflect}?.text
    }
    
    func getIntroText() -> String? {
        return self.content.first?.text
    }
    
    func getQuestionMarkdown() -> String? {
        let content = self.content.first {$0.contentType == .reflect}
        return FormatUtils.isBlank(content?.text_md) ? content?.text : content?.text_md
    }
}
