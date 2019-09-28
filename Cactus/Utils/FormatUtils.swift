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
        
        if input.isEmpty {
            return true
        }
        
        return false
    }
    
    static func responseText(_ responses: [ReflectionResponse]?) -> String? {
        return  responses?.map {$0.content.text ?? ""}.joined(separator: "\n\n")
    }
}

struct FontSize {
    static let large: CGFloat = 28
    static let normal: CGFloat = 16
}

struct CactusFont {    
    static let large = UIFont.systemFont(ofSize: FontSize.large)
    static let normal = UIFont.systemFont(ofSize: FontSize.normal)
}
