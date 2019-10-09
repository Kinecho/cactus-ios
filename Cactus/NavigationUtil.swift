//
//  Screens.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

enum ScreenID: String {
    //main
    case AppMain = "AppMain"
    case Home = "Home"
    case Login = "Login"
    case LaunchScreen = "LaunchScreen"
    case MemberProfile = "MemberProfile"
    case JournalFeed
    case JournalHome
    //settings
    case settingsTable
    case inviteScreen
    case notificationsScreen
    
    var name: String {
        return self.rawValue
    }
}

enum ReuseIdentifier: String {
    case JournalEntryCell
}

enum NibName: String {
    case TextContent = "TextContentViewController"

    var name: String {
        return self.rawValue
    }
}

enum StoryboardID: String {
    case LaunchScreen
    case Main
    case Settings

    var name: String {
        return self.rawValue
    }
    
    func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
}

enum SegueID: String {
    case ShowPromptContentModal
    case embedJournalFeed

    var name: String {
        return self.rawValue
    }
    
    static func fromString(_ input: String?) -> SegueID? {
        guard let input = input else {return nil}
        return SegueID(rawValue: input)
    }
}
