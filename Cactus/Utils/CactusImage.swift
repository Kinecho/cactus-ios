//
//  CactusImage.swift
//  Cactus
//
//  Created by Neil Poulin on 9/23/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import NoveFeatherIcons
import SwiftUI

struct Icon {
    static func getImage(_ name: String?) -> UIImage? {
        guard let name = name else {
            return nil
        }
        if let iconType = IconType(rawValue: name), iconType != .unknown {
            return iconType.image
        }
        return Feather.getIcon(name)
    }
    
    static func getImage(_ feather: Feather.IconName) -> UIImage? {
        return Feather.getIcon(feather)
    }
    
    static func getImage(_ icon: IconType) -> UIImage? {
        return icon.image
    }
}

enum IconType: String, Codable {
    case heart
    case check
    case lock
    case calendar
    case journal
    case pie
    case grid
    case airplane
    case angleLeft
    case angleRight
    case arrowLeft
    case arrowRight
    case bell
    case close
    case gear
    case dots
    case share
    case creditCard
    case trash
    case checkCircle
    case flame
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try IconType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    var image: UIImage? {
        switch self {
        case .pie:
            return CactusImage.pie.getImage()
        case .heart:
            return CactusImage.heart.getImage()
        case .check:
            return CactusImage.check.getImage()
        case .calendar:
            return CactusImage.calendar.getImage()
        case .journal:
            return CactusImage.journal.getImage()
        case .lock:
            return CactusImage.lock.getImage()        
        default:
            return UIImage(named: self.rawValue)
        }
    }
}

enum CactusImage: String {
    
    //Avatars
    case cactusAvatarOG = "avatar_cactusOG"
    case avatar1
    case avatar2
    case avatar3
    case avatar4
    case avatar5
    
    //Logos
    case logo
    
    //shapes
    case needlePattern    
    
    //blobs
    case blob0
    
    //Brands
    case twitter = "Twitter"
    case facebook = "Facebook"
    case google = "Google"
    case apple = "apple"
    case envelope
    
    //backgrounds
    case plusBg
    case grainy
    
    //Illustraions
    case pottedCactus
    
    //Elements
//    case experience_element_1 = "experience-1"
//    case experience_element_2 = "experience-2"
    case experience_element = "experience"
    
//    case meaning_element_1 = "meaning-1"
//    case meaning_element_2 = "meaning-2"
    case meaning_element = "meaning"
    
//    case relationships_element_1 = "relationships-1"
//    case relationships_element_2 = "relationships-2"
    case relationships_element = "relationships"
    
//    case energy_element_1 = "energy-1"
//    case energy_element_2 = "energy-2"
    case energy_element = "energy"
    
//    case emotions_element_1 = "emotions-1"
//    case emotions_element_2 = "emotions-2"
    case emotions_element = "emotions"
    
    //Element parts
    case emotions1
    case emotions2
    case emotions3
    case energy1
    case energy2
    case energy3
    case energy4
    case energy5
    case energy6
    case energy7
    case experience1
    case experience2
    case experience3
    case experience4
    case meaning1
    case meaning2
    case relationships1
    case relationships2
    case relationships3
    case relationships4
    case relationships5
    case relationships6
    case relationships7
    case relationships8
    case relationships9
    
    //Icons    
    case airplane
    case angleLeft
    case angleRight
    case arrowLeft
    case arrowRight
    case bell
    case close
    case gear
    case dots
    case share
    case creditCard
    case check
    case journal
    case lock
    case calendar
    case heart
    case pie
    case grid
    case trash
    case checkCircle
    case todayBlob1
    case todayBlob2
    case cvBlob
    case blobTriangle
    case vBackground
    case cvResultsBlob
    case cvBlob1
    case cvBlob2
    case cvBlob3
    case cvBlob4
    case cvBlob5
    case cvBlob6
    case cvBlob7
    case cvBlob8
    case errorBlob
    case emptyState
    
    func getImage() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
    
    var swiftImage: Image {
        return Image(self.rawValue)
    }
    
    static func forElement(_ element: CactusElement, width: CGFloat? = nil, height: CGFloat? = nil) -> UIImage? {
        var image: CactusImage
        switch element {
        case .experience:
            image = CactusImage.experience_element
        case .energy:
            image = CactusImage.energy_element
        case .meaning:
            image = CactusImage.meaning_element
        case .emotions:
            image = CactusImage.emotions_element
        case .relationships:
            image = CactusImage.relationships_element
        }
        
        if let width = width, let height = height {
            return image.ofSize(CGSize(width: width, height: height))
        } else if let width = width {
            return image.ofWidth(newWidth: width)
        }
        return image.getImage()
    }
    
    func ofWidth(newWidth: CGFloat) -> UIImage? {
        guard let image = getImage() else { return nil}
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func ofSize(_ size: CGSize) -> UIImage? {
        guard let image = getImage() else {return nil}
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(0, 0, size.height, size.width))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    static func fromProviderId(_ providerId: String) -> UIImage? {
        switch providerId {
        case "google.com":
            return CactusImage.google.getImage()
        case "facebook.com":
            return CactusImage.facebook.getImage()
        case "twitter.com":
            return CactusImage.twitter.getImage()
        case "password":
            return CactusImage.envelope.getImage()
        case "apple.com":
            return CactusImage.apple.getImage()
        default:
            return nil
        }
    }
}
