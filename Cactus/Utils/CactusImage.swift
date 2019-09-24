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
    case twitter = "Twitter"

    func getImage() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}
