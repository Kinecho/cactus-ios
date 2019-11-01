//
//  SharingService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/29/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
func getInviteLink() -> String {
    let member = CactusMemberService.sharedInstance.currentMember
    let email = member?.email ?? ""
    return "\(CactusConfig.webDomain)?ref=\(email)&utm_source=cactus_ios&utm_medium=invite-friends"
}

func getInviteText() -> String {
    let member = CactusMemberService.sharedInstance.currentMember
    let pronoun = member?.firstName ?? member?.email ?? "me"
    
    return "Join \(pronoun) on Cactus"
}

func getPromptShareLink(_ promptContent: PromptContent) -> String {
    guard let entryId = promptContent.entryId else {
        return "\(CactusConfig.webDomain)"
    }
    return "\(CactusConfig.webDomain)/prompts/\(entryId)"
}

func getPromptShareText(_ promptContent: PromptContent) -> String {
    guard let subject = promptContent.subjectLine else {return "Check out this prompt on Cactus"}
    return subject
}

class InviteShareItem: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return getInviteLink()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return getInviteText()
    }
        
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        let defaultItem = getInviteLink()
        guard let activityType = activityType else {
            return defaultItem
        }
        
        switch activityType {
        case .message:
            return "\(getInviteText())\n\n\(getInviteLink())"
        default:
            return defaultItem
        }
    }
}

class PromptShareItem: NSObject, UIActivityItemSource {
    let promptContent: PromptContent!
    
    init(_ promptContent: PromptContent) {
        self.promptContent = promptContent
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return getPromptShareLink(self.promptContent)
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return getPromptShareText(self.promptContent)
    }
        
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        let defaultItem = "\(getPromptShareText(self.promptContent))\n\n\(getPromptShareLink(self.promptContent))"
        guard let activityType = activityType else {
            return defaultItem
        }
        
        switch activityType {
        default:
            return defaultItem
        }
    }
}
