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
    case Login = "Login"
    case LaunchScreen = "LaunchScreen"
    case JournalFeed
    case JournalHome
    case elementsPageView
    case journalEmpty
    case promptContentPageView
    //settings
    case settingsTable
    case inviteScreen
    case notificationsScreen
    
    //Onboarding
    case notificationOnboarding
    
    var name: String {
        return self.rawValue
    }
    
    var storyboardID: StoryboardID {
        switch self {
        case .settingsTable,
             .inviteScreen,
             .notificationsScreen:
            return StoryboardID.Settings
        case .notificationOnboarding:
            return StoryboardID.Onboarding
        default:
            return StoryboardID.Main
        }
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
    case Onboarding

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
