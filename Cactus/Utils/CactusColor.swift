//
//  CactusColor.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum NamedColor: String, Codable, CaseIterable {
    case AccentBeige
    case AlertYellow
    case Aqua
    case Background
    case Beige
    case BeigeDark
    case BlackInvertable
    case BlueLight
    case BorderLight
    case CardBackground
    case Coral
    case DisabledButtonBackground
    case Danger
    case Dolphin
    case DolphinLight
    case Facebook
    case FancyLinkHighlight
    case GrayLight
    case Gray
    case GrayDark
    case GreenLightest
    case GreenLight
    case Green
    case GreenDark
    case GreenDarker
    case GreenDarkest
    case GreenRoyal
    case Heading3Text
    case Highlight
    case HighContrast
    case Indigo
    case TextBoldHighlight
    case Lightest
    case Magenta
    case MenuBackground
    case NoteBackground
    case PaymentBackground
    case PinkBright
    case PinkLightest
    case PinkLight
    case Pink
    case PinkDark
    case PinkDarkest
    case PromptBackground
    case ProgressBackground
    case Royal
    case SecondaryButtonBackground
    case SecondaryBorder
    case SkeletonBase
    case StatIconBackground
    case TextDark
    case TextDefault
    case TextLight
    case TextMinimized
    case TextPlaceholder
    case TextWhite
    case TodayWidgetBackground
    case Twitter
    case White
    case WhiteInvertable
    case Yellow
    case YellowDark
    case YellowDarkest
    
    /// set up aliases for named colors
    static let LinkColor = NamedColor.GreenDark
    static let SelectedBuyable = NamedColor.Highlight
    
    var uiColor: UIColor {
        UIColor(named: self.rawValue)!
    }
    
    var color: SwiftUI.Color {
        SwiftUI.Color(self.rawValue)
    }
}

struct ColorInfo {
    var namedColor: NamedColor
    var hex: String?
    
    var uiColor: UIColor {
        self.namedColor.uiColor
    }
    
    var color: SwiftUI.Color {
        self.namedColor.color
    }
}

/// Deprecated Struct for getting UI Colors
struct CactusColor {
    static let beige = NamedColor.Beige.uiColor
    static let borderLight = NamedColor.BorderLight.uiColor
    static let cardBackground = NamedColor.CardBackground.uiColor
    static let darkText = NamedColor.TextDark.uiColor
    static let darkGray = NamedColor.GrayDark.uiColor
    static let darkPink = NamedColor.PinkDark.uiColor
    static let darkestPink = NamedColor.PinkDarkest.uiColor
    static let darkGreen = NamedColor.GreenDark.uiColor
    static let darkerGreen = NamedColor.GreenDarker.uiColor
    static let darkestGreen = NamedColor.GreenDarkest.uiColor
    static let darkYellow = NamedColor.YellowDark.uiColor
    static let darkestYellow = NamedColor.YellowDarkest.uiColor
    static let facebook = NamedColor.Facebook.uiColor
    static let gray = NamedColor.Gray.uiColor
    static let green = NamedColor.Green.uiColor
    static let greenRoyal = NamedColor.GreenRoyal.uiColor
    static let highContrast = NamedColor.HighContrast.uiColor
    static let indigo = NamedColor.Indigo.uiColor
    static let lightBlue = NamedColor.BlueLight.uiColor
    static let lightestGreen = NamedColor.GreenLightest.uiColor
    static let lightGreen = NamedColor.GreenLight.uiColor
    static let lightest = NamedColor.Lightest.uiColor
    static let lightText = NamedColor.TextLight.uiColor
    static let lightGray = NamedColor.GrayLight.uiColor
    static let lightestPink = NamedColor.PinkLightest.uiColor
    static let lightPink = NamedColor.PinkLight.uiColor
    static let paymentBackground = NamedColor.PaymentBackground.uiColor
    static let pink = NamedColor.Pink.uiColor
    static let placeholderText = NamedColor.TextPlaceholder.uiColor
    static let twitter = NamedColor.Twitter.uiColor
    static let yellow = NamedColor.Yellow.uiColor
    static let textBoldHighlight = NamedColor.TextBoldHighlight.uiColor
    static let whiteInvertable = NamedColor.WhiteInvertable.uiColor
    static let blackInvertable = NamedColor.BlackInvertable.uiColor
    static let white = NamedColor.White.uiColor
    static let background = NamedColor.Background.uiColor
    static let noteBackground = NamedColor.NoteBackground.uiColor
    static let darkBeige = NamedColor.BeigeDark.uiColor
    static let magenta = NamedColor.Magenta.uiColor
    static let menuBackground = NamedColor.MenuBackground.uiColor
    static let dolphin = NamedColor.Dolphin.uiColor
    static let dolphinLight = NamedColor.DolphinLight.uiColor
    static let promptBackground = NamedColor.PromptBackground.uiColor
    static let accentBeige = NamedColor.AccentBeige.uiColor
    static let alertYellow = NamedColor.AlertYellow.uiColor
    static let progressBackground = NamedColor.ProgressBackground.uiColor
    static let textDefault = NamedColor.TextDefault.uiColor
    static let textWhite = NamedColor.TextWhite.uiColor
    static let heading3Text = NamedColor.Heading3Text.uiColor
    static let textMinimized = NamedColor.TextMinimized.uiColor
    static let secondaryButtonBackground = NamedColor.SecondaryButtonBackground.uiColor
    static let secondaryBorder = NamedColor.SecondaryBorder.uiColor
    static let skeletonBase = NamedColor.SkeletonBase.uiColor
    static let brightPink = NamedColor.PinkBright.uiColor
    static let royal = NamedColor.Royal.uiColor
    static let aqua = NamedColor.Aqua.uiColor
    static let fancyLinkHighlight = NamedColor.FancyLinkHighlight.uiColor
    static let highlight = NamedColor.Highlight.uiColor
    static let danger = NamedColor.Danger.uiColor
    static let coral = NamedColor.Coral.uiColor
    static let linkColor = NamedColor.LinkColor.uiColor
}

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
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
