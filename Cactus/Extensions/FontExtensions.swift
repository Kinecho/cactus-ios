//
//  FontExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 9/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
extension UILabel {
    var substituteFontName: String {
        get { return self.font.fontName }
        set {
            if self.font?.fontName.range(of: "Bold") == nil {
                self.font = UIFont(name: newValue, size: self.font?.pointSize ?? 17)
            }
        }
    }
    var substituteFontNameBold: String {
        get { return self.font.fontName }
        set {
            if self.font?.fontName.range(of: "Bold") != nil {
                self.font = UIFont(name: newValue, size: self.font?.pointSize ?? 17)
            }
        }
    }
}
extension UITextField {
    var substituteFontName: String {
        get { return (self.font?.fontName ?? FontName.normal.rawValue) }
        set {
            self.font = UIFont(name: newValue, size: (self.font?.pointSize ?? 17)!)
        }
    }
}
extension UIFont {
    class func appRegularFontWith(size: CGFloat) -> UIFont {
        return  CactusFont.normal(size)
    }
    class func appBoldFontWith(size: CGFloat) -> UIFont {
        return  CactusFont.bold(size)
    }
}
