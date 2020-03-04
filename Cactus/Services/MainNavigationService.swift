//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

import UIKit

class MainNavigationService {
    static var sharedInstance = MainNavigationService()
    
    func getScreen(_ screen: ScreenID) -> UIViewController {
        let storyboard = screen.storyboardID.getStoryboard()
        return storyboard.instantiateViewController(withIdentifier: screen.name)
    }
}
