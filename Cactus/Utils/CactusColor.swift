//
//  CactusColor.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

struct CactusColor {
    static let lightest: UIColor = UIColor(hex: "F1EBE7")
    
    static let lightText: UIColor = UIColor(hex: "757575")
    static let darkText: UIColor = UIColor(hex: "444444")
    static let textDefault: UIColor = CactusColor.darkestGreen
    static let placeholderText: UIColor = UIColor(hex: "757575")
    
    static let lightGray: UIColor = UIColor(hex: "E2E2E2")
    static let gray: UIColor = UIColor(hex: "CCCCCC")
    static let darkGray: UIColor = UIColor(hex: "444444")
    
    static let lightestPink: UIColor = UIColor(hex: "FFF2ED")
    static let lightPink: UIColor = UIColor(hex: "FFE4DA")
    static let pink: UIColor = UIColor(hex: "FFE4DA")
    static let darkPink: UIColor = UIColor(hex: "FDBCA3")
    static let darkestPink: UIColor = UIColor(hex: "7A3814")
    
    static let lightGreen: UIColor = UIColor(hex: "B9EFE9")
    static let green: UIColor = UIColor(hex: "33CCAB")
    static let darkGreen: UIColor = UIColor(hex: "29A389")
    static let darkestGreen: UIColor = UIColor(hex: "07454C")
    
    static let yellow: UIColor = UIColor(hex: "F9EB91")
    static let darkYellow: UIColor = UIColor(hex: "F4DD48")
    static let darkestYellow: UIColor = UIColor(hex: "F4DD48")
    
    static let lightBlue: UIColor = UIColor(hex: "e6f9f7")
    
    static let borderLight: UIColor = UIColor(hex: "f1ebe7")
    
    static let facebook: UIColor = UIColor(hex: "3b5998")
    static let twitter: UIColor = UIColor(hex: "1da1f2")
    
    static let white: UIColor = UIColor(hex: "FFFFFF")
    
}

extension UIColor {
    
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            self.init()
            return
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
