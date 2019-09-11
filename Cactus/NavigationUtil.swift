//
//  Screens.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

enum ScreenID:String {
    case AppMain
    case Home
    case Login
    case LaunchScreen
    case MemberProfile
    case JournalFeed
    
    var name: String {
        get {            
            return self.rawValue
        }
    }
}

enum NibName:String {
    case TextContent = "TextContentViewController"
    
    var name: String {
        get {
            return self.rawValue
        }
    }
}

enum StoryboardID:String {
    case LaunchScreen
    case Main
    
    var name:String {
        get {return self.rawValue}
    }
}

enum SegueID:String {
    case ShowPromptContentModal
    
    var name:String {
        get {return self.rawValue}
    }
}
