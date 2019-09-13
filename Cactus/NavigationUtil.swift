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
    case appMain
    case home
    case login
    case launchScreen
    case memberProfile
    case journalFeed

    var name: String {
        return self.rawValue
    }
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
