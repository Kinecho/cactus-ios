//
//  CactusElements.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum CactusElement: String, Codable, CaseIterable {
    case energy = "energy"
    case experience = "experience"
    case relationships = "relationships"
    case emotions = "emotions"
    case meaning = "meaning"
    
    static let orderedElements: [CactusElement] = [.energy, .relationships, .meaning, .emotions, .experience]
    static let elementsAlphabetical: [CactusElement] = CactusElement.allCases.sorted { (e1, e2) -> Bool in
        return e1.rawValue < e2.rawValue
    }
    
    var color: UIColor {
        switch self {
        case .emotions:
            return CactusColor.green
        case .energy:
            return CactusColor.pink
        case .experience:
            return CactusColor.royal
        case .meaning:
            return CactusColor.coral
        case .relationships:
            return CactusColor.dolphinLight
        }
    }
    
    func getImage(width: CGFloat?=nil, height: CGFloat?=nil) -> UIImage? {
        return CactusImage.forElement(self, width: width, height: height)
    }
    
    var title: String {
        self.rawValue.capitalized
    }
    
    func getStatImage(_ stat: Int) -> UIImage? {
        var suffix = "-\(stat)"
        if stat >= 3 {
            suffix = "Full"
        }
        
        let name = "\(self.rawValue)\(suffix)"
        Logger.shared.info("Getting elememnt stat image with name \(name)")
        return UIImage(named: name)
    }
    
    var description: String {
        return getElementDescription(self)
    }
}

func getElementDescription(_ element: CactusElement) -> String {
    switch element {
    case .energy:
        return "Caring for your physical health and managing the mind-body connection"
    case .experience:
        return "Exploring your intellectual curiosities and openly observing life’s lessons"
    case .emotions:
        return "Embracing the spectrum of emotions as you strive for optimism"
    case .relationships:
        return "Developing rewarding and fulfilling relationships with yourself and others"
    case .meaning:
        return "Living with a sense of purpose while you enjoy the present"
    }
}
