//
//  SharingService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/29/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FBSDKCoreKit

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
    guard let subject = promptContent.subjectLine ?? promptContent.getIntroText() else {
        return "Cactus Mindful Moment"
        
    }
    return subject
}

func getShareActivityTypeDisplayName(_ activityType: UIActivity.ActivityType?) -> String {
    guard let activityType = activityType else {
        return "unknown"
    }
    
    switch activityType {
    case .copyToPasteboard:
        return "Copy to Pasteboard"
    case .addToReadingList:
        return "Add to Reading List"
    case .airDrop:
        return "AirDrop"
    case .assignToContact:
        return "Assign to Contact"
    case .mail:
        return "Mail"
    case .markupAsPDF:
        return "Markup as PDF"
    case .message:
        return "Message"
    case .openInIBooks:
        return "Open In iBooks"
    case .postToFacebook:
        return "Post to Facebook"
    case .postToFlickr:
        return "Post to Flickr"
    case .postToTwitter:
        return "Post to Twitter"
    case .postToVimeo:
        return "Post to Vimeo"
    case .postToWeibo:
        return "Post to Webio"
    case .print:
        return "Print"
    case .saveToCameraRoll:
        return "Save to Camera Roll"
    default:
        return activityType.rawValue
    }
}

class InviteShareItem: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return getInviteLink()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return getInviteText()
    }
    
    func getURL() -> URL? {        
        return URL(string: getInviteLink())
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let defaultItem = "\(getInviteText())"
        guard let activityType = activityType else {
            return defaultItem
        }

        switch activityType {
        case .copyToPasteboard:
            return nil
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
    
    func getShareURL() -> URL? {
        let link = getPromptShareLink(self.promptContent)
        return URL(string: link)
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let defaultItem: Any = "\(getPromptShareText(self.promptContent))"
        guard let activityType = activityType else {
            return nil
        }
        
        switch activityType {
        case .copyToPasteboard:
            return nil
        default:
            return defaultItem
        }
    }
}

class ReflectionShareItem: NSObject, UIActivityItemSource {
    let promptContent: PromptContent!
    let reflectionResponse: ReflectionResponse!
    let logger = Logger("ReflectShareItem")
    
    init(_ reflectionResponse: ReflectionResponse, _ promptContent: PromptContent) {
        self.promptContent = promptContent
        self.reflectionResponse = reflectionResponse
    }
    
    func getShareTitle() -> String {
//        let member = CactusMemberService.sharedInstance.currentMember
        let pronoun = "my"
//        if let firstName = member?.firstName {
//            pronoun = "\(firstName)'s"
//        }
        
        var subject = ""
        if self.question != nil {
            subject = "on \"\(self.question!)\""
        }
        return "Read \(pronoun) private note \(subject)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getPromptQuestion() -> String {
        return self.promptContent.getQuestion() ?? self.reflectionResponse?.promptQuestion ?? ""
    }
    
    func getLink() -> String? {
        guard let id = self.reflectionResponse.id else {
            return nil
        }
        return "\(CactusConfig.webDomain)/reflection/\(id)?utm_source=cactus_ios&utm_medium=share-note"
    }
    
    func getShareURL() -> URL? {
        guard let link = self.getLink() else {
            return nil
        }
        return URL(string: link)
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.getShareURL() ?? self.getLink() ?? self.getShareTitle()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return getShareTitle()
    }
    
    var question: String? {
         self.reflectionResponse?.promptQuestion ?? self.promptContent.getQuestion()
    }
    
    var questionAndResponseText: String {
        "\(self.question ?? "")\n\n\(self.reflectionResponse.content.text ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let activityType = activityType else {
            return getShareURL()
        }
           
        let questionNoteAndLink = "\(self.questionAndResponseText)\n\n\(self.getLink() ?? "")"
        let introAndLink = "\(getShareTitle())\n\n\(getLink() ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        switch activityType {
        case UIActivity.ActivityType("com.tinyspeck.chatlyio.share"):
            return introAndLink
        case .postToFacebook:
            return introAndLink
        case UIActivity.ActivityType("com.bloombuilt.dayone-ios.Share"):
            return questionNoteAndLink
        case UIActivity.ActivityType("com.google.Gmail.ShareExtension"):
            return questionNoteAndLink
        default:
            return getShareURL()
        }
    }
}

class CopyLinkActivity: UIActivity {
    var url: URL?
    var title = "Copy Link"
        
    override var activityType: UIActivity.ActivityType? {ActivityType("com.cactus.copyLink")}
    override var activityTitle: String? {self.title}
    override var activityImage: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "link")
        } else {
            return UIImage(named: "link")
        }
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.contains { (item) -> Bool in
            return item is URL
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        let url = activityItems.first { (item) -> Bool in
            return item is URL
        }
        self.url = url as? URL
    }
    
    override func perform() {
        if let link = self.url?.absoluteString {
            UIPasteboard.general.string = link
        }
        activityDidFinish(true)
    }
    
}

class CopyTextActivity: UIActivity {
    var text: String
    var title = "Copy Note"
    
    init(_ text: String, title: String?=nil) {
        self.text = text
        if let title = title {
            self.title = title
        }
    }
    
    override var activityType: UIActivity.ActivityType? {ActivityType("app.cactus.copyText")}
    override var activityTitle: String? {self.title}
    override var activityImage: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "doc.on.clipboard.fill")
        } else {
            return UIImage(named: "doc")
        }
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        UIPasteboard.general.string = self.text
        activityDidFinish(true)
    }
    
}

/**
 A Service to share items in a consistent manner across the app
 */
class SharingService {
    static var shared = SharingService()
    
    let logger = Logger("SharingService")
    
    func sharePromptCompleted(_ promptContent: PromptContent, activityType: UIActivity.ActivityType?) {
        let subjectLine = promptContent.subjectLine ?? ""
        let promptId = promptContent.promptId ?? "unknown"
        let typeString = getShareActivityTypeDisplayName(activityType)
        self.logger.sentryInfo(":share: :white_check_mark: Prompt shared via \(typeString). " +
            "SubjectLine=\"\(subjectLine)\" promptId=\(promptId)")
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: "sharePrompt",
            AnalyticsParameterItemID: promptId
        ])
    }
    
    func sharePromptCanceled(_ promptContent: PromptContent) {
        let subjectLine = promptContent.subjectLine ?? ""
        let promptId = promptContent.promptId ?? "unknown"
        self.logger.sentryInfo(":share: :x: Share Prompt action canceled. SubjectLine=\"\(subjectLine)\" promptId=\(promptId)")
    }
    
    /**
     Present the she sheet for a prompt content item. This method will handle logging analytics events
     - Parameter promptContent: PromptContent - the PromptContent to share
     - Parameter target: The UIViewController that should present the share sheet
     */
    func sharePromptContent(promptContent: PromptContent, target: UIViewController, sender: UIView?) {
        let subjectLine = promptContent.subjectLine ?? ""
        let promptId = promptContent.promptId ?? "unknown"
        self.logger.sentryInfo(":share: :hourglass: Share Prompt share sheet presented. SubjectLine=\"\(subjectLine)\" promptId=\(promptId)")
        
        var items: [Any] = [PromptShareItem(promptContent)]
        if let shareUrl = URL(string: getPromptShareLink(promptContent)) {
            items.append(shareUrl)
        }
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = sender
        
        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .openInIBooks]
        
        ac.completionWithItemsHandler = { activityType, completed, items, error in
            if completed {
                self.sharePromptCompleted(promptContent, activityType: activityType)
            } else {
                self.sharePromptCanceled(promptContent)
            }
            
            if let error = error {
                self.logger.error("Failed to share prompt", error)
            }
        }
        
        target.present(ac, animated: true)
    }
    
    func shareNoteCompleted(promptContent: PromptContent, activityType: UIActivity.ActivityType?) {
        let subjectLine = promptContent.subjectLine ?? ""
        let promptId = promptContent.promptId ?? "unknown"
        let typeString = getShareActivityTypeDisplayName(activityType)
        self.logger.sentryInfo(":share: :white_check_mark: Note shared via \(typeString). " +
            "SubjectLine=\"\(subjectLine)\" promptId=\(promptId)")
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: "shareReflectionNote",
            AnalyticsParameterItemID: promptId
        ])
    }
    
    func shareNote(response: ReflectionResponse, promptContent: PromptContent, target: UIViewController, sender: UIView) {
        let subjectLine = promptContent.subjectLine ?? ""
        let promptId = promptContent.promptId ?? "unknown"
        
        self.logger.sentryInfo(":share: :hourglass: Share Note share sheet tapped. SubjectLine=\"\(promptContent.subjectLine ?? "")\" promptId=\(promptId)")
        var items: [Any] = []
        let shareItem = ReflectionShareItem(response, promptContent)
        items.append(shareItem)

        var activities: [UIActivity] = [CopyLinkActivity()]
        
        if let note = response.content.text {
            activities.append(CopyTextActivity(note))
        }
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: activities)
        ac.popoverPresentationController?.sourceView = sender
        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .openInIBooks, .copyToPasteboard]
        
        ac.completionWithItemsHandler = { activityType, completed, items, error in
            if completed {
                self.shareNoteCompleted(promptContent: promptContent, activityType: activityType)
                
            } else {
                self.logger.sentryInfo(":share: :x: Share Note action canceled. SubjectLine=\"\(subjectLine)\" promptId=\(promptId)")
            }
            
            if let error = error {
                self.logger.error("Failed to share note", error)
            }
        }
        target.present(ac, animated: true)
    }
}
