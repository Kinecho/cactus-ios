//
//  SharingService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/29/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
func getShareLink() -> String {
    let member = CactusMemberService.sharedInstance.currentMember
    let email = member?.email ?? ""
    return "https://cactus.app?ref=\(email)&utm_source=cactus_ios&utm_medium=invite-friends"
}

func getInviteText() -> String {
    let member = CactusMemberService.sharedInstance.currentMember
    let pronoun = member?.firstName ?? member?.email ?? "me"
    
    return "Join \(pronoun) on Cactus"
}

class InviteShareItem: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return getShareLink()
    }


    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return getInviteText()
    }
        
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        let defaultItem = getShareLink()
        guard let activityType = activityType else  {
            return defaultItem
        }
        
        switch activityType {
        case .message:
            return "\(getShareLink())\n\(getShareLink())"
        default:
            return defaultItem
        }
        
        
    }
}
