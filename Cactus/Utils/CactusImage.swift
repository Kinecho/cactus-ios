//
//  CactusImage.swift
//  Cactus
//
//  Created by Neil Poulin on 9/23/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

enum CactusImage: String {
    case cactusAvatarOG = "avatar_cactusOG"
    
    //Logos
    case logo
    
    //Brands
    case twitter = "Twitter"
    case facebook = "Facebook"
    case google = "Google"
    case envelope

    //Illustraions
    case pottedCactus
    
    //Elements
    case experience_element = "experienceFull"
    case meaning_element = "meaningFull"
    case relationships_element = "relationshipsFull"
    case energy_element = "energyFull"
    case emotions_element = "emotionsFull"
    
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
    
    func getImage() -> UIImage? {
        return UIImage(named: self.rawValue)
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
        default:
            return nil
        }
    }
}
