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
    
    func ofWidth(newWidth: CGFloat) -> UIImage? {
        guard let image = getImage() else { return nil}
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
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
