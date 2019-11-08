//
//  FormatUtils.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

struct FormatUtils {
    static func formatDate(_ date: Date?, currentYearFormat: String="MMMM d", previousYearFormat: String="MMM d, yyyy") -> String? {
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

struct FontSize {
    static let large: CGFloat = 28
    static let normal: CGFloat = 18
}

struct CactusFont {
    static let normal = UIFont(name: FontName.normal.rawValue, size: FontSize.normal)!
    static let large = UIFont(name: FontName.normal.rawValue, size: FontSize.large)!
    static let normalBold = UIFont(name: FontName.bold.rawValue, size: FontSize.normal)!
    
    static func get(_ name: FontName, _ size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size)!
    }
    
    static func normal(_ size: CGFloat) -> UIFont {
        return get(FontName.normal, size)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return get(FontName.bold, size)
    }
}
