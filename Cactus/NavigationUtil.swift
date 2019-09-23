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
    case AppMain = "AppMain"
    case Home = "Home"
    case Login = "Login"
    case LaunchScreen = "LaunchScreen"
    case MemberProfile = "MemberProfile"
    case JournalFeed
    case JournalHome

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

    var name: String {
        return self.rawValue
    }
}

enum SegueID: String {
    case ShowPromptContentModal

    var name: String {
        return self.rawValue
    }
}
