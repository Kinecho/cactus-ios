//
//  FormatUtils.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

func toEmptyString(_ input: String?) -> String {
    return input ?? ""
}

func isBlank(_ input: String? ) -> Bool {
    return FormatUtils.isBlank(input)
}

func formatApplePrice(_ price: NSDecimalNumber?, locale: Locale?) -> String? {
    guard let price = price else {
        return nil
    }
    return formatApplePrice(price, locale: locale)
}

func formatApplePrice(_ price: NSDecimalNumber, locale: Locale?) -> String? {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency    
    currencyFormatter.locale = locale ?? Locale.init(identifier: "en-US")
    return currencyFormatter.string(from: price)
}

func formatPriceCents(_ price: Int?, truncateWholeDollar: Bool = true, currencySymbol: String?=nil) -> String? {
    guard let price = price else {
        return nil
    }
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    if price % 100 == 0 && truncateWholeDollar {
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
    } else {
        currencyFormatter.numberStyle = .currency
    }
    
    currencyFormatter.locale = Locale.init(identifier: "en-US")
    
    if let symbol = currencySymbol {
        currencyFormatter.currencySymbol = symbol
    }
    
    return currencyFormatter.string(from: NSNumber(value: Double(price)/100))
}

struct CactusDateFormat {
    static let journalCurrentYear = "MMMM d"
    static let journalPastYear = "MMMM d, yyyy"
}

struct FormatUtils {
    static func hasChanges(_ input: String?, _ original: String?) -> Bool {
        return toEmptyString(input).trimmingCharacters(in: .whitespacesAndNewlines) != toEmptyString(original).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func localizedDate(_ date: Date?, dateStyle: DateFormatter.Style = .full, timeStyle: DateFormatter.Style = .none) -> String? {
        var dateString: String?
        if let date = date {
            let df = DateFormatter()
            df.dateStyle = dateStyle
            df.timeStyle = timeStyle
            dateString = df.string(from: date)
        }
        return dateString
    }
    
    static func formatDate(_ date: Date?, currentYearFormat: String="MMMM d", previousYearFormat: String="MMMM d, yyyy") -> String? {
        var dateString: String?
        if let date = date {
            let df = DateFormatter()
            let calendar = Calendar.current
            let dateYear = calendar.component(.year, from: date)
            let currentYear = calendar.component(.year, from: Date())
            if currentYear > dateYear {
                df.dateFormat = previousYearFormat
            } else {
                df.dateFormat = currentYearFormat
            }
            
            dateString = df.string(from: date)
        }
        return dateString
    }
    
    static func isBlank(_ input: String?) -> Bool {
        guard let input = input else {
            return true
        }
        
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        
        return false
    }
    
    static func wrapInDoubleQuotes(input: String?) -> String? {
        guard let input = input else {
            return nil
        }
        
        return "\"\(input)\""
    }
    
    static func responseText(_ responses: [ReflectionResponse]?) -> String? {
        return  responses?.map {$0.content.text ?? ""}.joined(separator: "\n\n")
    }
}

func isValidEmail(_ emailStr: String?) -> Bool {
    guard let email = emailStr else {return false}
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

enum FontName: String {
    case normal = "Lato-Regular"
    case bold = "Lato-Bold"
    case italic = "Lato-Italic"
    case boldItalic = "Lato-BoldItalic"
}

enum FontSize: CGFloat {
    case large = 28
    case title = 21
    case normal = 18
    case subTitle = 16
   
    // Aliases
    static let journalDate: FontSize = .subTitle
    static let journalQuestionTitle: FontSize = .title
}

enum Kerning: CGFloat {
    case normal = 0
    case title = 2
}

func getProviderDisplayName(_ providerId: String) -> String? {
    switch providerId {
    case "google.com":
        return "Google"
    case "twitter.com":
        return "Twitter"
    case "facebook.com":
        return "Facebook"
    case "password":
        return "Email/Password"
    case "apple.com":
        return "Apple"
    default:
        return nil
    }
}


struct CactusFont {
    static let normal = UIFont(name: FontName.normal, size: FontSize.normal)
    static let large = UIFont(name: FontName.normal, size: FontSize.large)
    static let normalBold = UIFont(name: FontName.bold, size: FontSize.normal)
    
    static func get(_ name: FontName, _ size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size)!
    }
    
    static func get(_ name: FontName, _ size: FontSize) -> UIFont {
        return UIFont(name: name, size: size)
    }
    
    static func normal(_ size: CGFloat) -> UIFont {
        return get(FontName.normal, size)
    }
    
    static func normal(_ size: FontSize) -> UIFont {
        return get(FontName.normal, size)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return get(FontName.bold, size)
    }
    
    static func bold(_ size: FontSize) -> UIFont {
        return get(FontName.bold, size)
    }
    
    static func italic(_ size: CGFloat) -> UIFont {
        return get(FontName.italic, size)
    }
    
    static func italic(_ size: FontSize) -> UIFont {
        return get(FontName.italic, size)
    }
}

func destructureDisplayName(displayName: String?) -> (firstName: String?, lastName: String?) {
    var lastName: String?
    var firstName: String?
    if var components = displayName?.components(separatedBy: " ") {
        if components.count > 0 {
            firstName = components.removeFirst()
            lastName = components.joined(separator: " ")
        }
    }
    return (firstName: firstName, lastName: lastName)
}

extension UIFont {
    var font: Font {
        return Font(self)
    }
}
