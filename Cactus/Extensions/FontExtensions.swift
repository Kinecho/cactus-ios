//
//  FontExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 9/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func appRegularFontWith(size: CGFloat) -> UIFont {
        return  CactusFont.normal(size)
    }
    class func appBoldFontWith(size: CGFloat) -> UIFont {
        return  CactusFont.bold(size)
    }
    
    convenience init(name: FontName, size: FontSize) {
        self.init(name: name.rawValue, size: size.rawValue)!
    }
}
