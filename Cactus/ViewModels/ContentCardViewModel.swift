//
//  ContentCardViewModel.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

enum Card: Identifiable {
    case text(TextCardViewModel)
    case reflect(ReflectCardViewModel)
    
    var id: Int {
        switch self {
        case .text:
            return 1
        case .reflect:
            return 2        
        }
    }
    
    var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .reflect:
            return "Reflect"
        default:
            return "Unknokwn"
        }
    }
}

enum CardType {
    case text
    case quote
    case reflect
    case audio
    case video
    case insights
    case photo
    case shareNote
    case elements
    case invite
    case unknown
    
    static func fromContentType(_ contentType: ContentType) -> CardType {
        switch contentType {
        case .audio:
            return .audio
        case .text:
            return .text
        case .quote:
            return .quote
        case .video:
            return .video
        case .photo:
            return .photo
        case .reflect:
            return .reflect
        case .share_reflection:
            return .shareNote
        case .elements:
            return .elements
        case .invite:
            return .invite
        case .unknown:
            return .unknown
        }
    }
}

protocol CardViewModel {
    var cardType: CardType { get }
}

class ContentCardViewModel: Identifiable {
//    let cardType: CardType
    var id: UUID = UUID()
    var content: Content
    var promptContent: PromptContent
    var prompt: ReflectionPrompt?
    var member: CactusMember?
    var responses: [ReflectionResponse]?
    
    init(promptContent: PromptContent, content: Content, prompt: ReflectionPrompt? = nil, responses: [ReflectionResponse]? = nil, member: CactusMember? = nil) {
//        self.cardType = CardType.fromContentType(content.contentType)
        self.content = content
        self.promptContent = promptContent
        self.responses = responses
        self.prompt = prompt
        self.member = member
    }
    
    init(_ card: ContentCardViewModel) {
        self.content = card.content
        self.promptContent = card.promptContent
        self.prompt = card.prompt
        self.member = card.member
        self.responses = card.responses
    }
    
    static func create(_ entry: JournalEntry, content: Content, member: CactusMember?) -> Card? {
        guard let promptContent = entry.promptContent else {
            return nil
        }
        
        let prompt = entry.prompt
        let responses = entry.responses
        let contentModel = ContentCardViewModel(promptContent: promptContent, content:content, prompt: prompt, responses: responses, member: member)
        switch content.contentType {
        case .text:
            return .text(TextCardViewModel(contentModel))
//        case .audio:
//            return .audio
//        case .quote:
//            return .quote
//        case .video:
//            return .video
//        case .photo:
//            return .photo
        case .reflect:
            return .reflect(ReflectCardViewModel(contentModel))
//        case .share_reflection:
//            return .shareNote
//        case .elements:
//            return .elements
//        case .invite:
//            return .invite
//        case .unknown:
//            return .unknown
        default:
            return nil
        }
        
    }
    
    static func createAll(_ entry: JournalEntry, member: CactusMember?) -> [Card] {
        let cards = entry.promptContent?.content.compactMap({ (content) -> Card? in
            ContentCardViewModel.create(entry, content: content, member: member)
        })
        
        
        
        return cards ?? []
    }
}

class TextCardViewModel: ContentCardViewModel {
    
    var imageUrl: URL? {
        let photo = self.content.backgroundImage
        return ImageService.shared.getUrlFromFile(photo)
    }
    
    var textMarkdown: String? {
        let coreValue = self.responses?.first{$0.coreValue != nil}?.coreValue
        let dynamicValues = self.responses?.first{$0.dynamicValues != nil}?.dynamicValues
        return self.content.getDisplayText(member: self.member, preferredIndex: self.promptContent.preferredCoreValueIndex, coreValue: coreValue, dynamicValues: dynamicValues)
    }
}

class ReflectCardViewModel: ContentCardViewModel {
    
}
