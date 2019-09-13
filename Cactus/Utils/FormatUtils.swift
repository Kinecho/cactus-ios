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
    
    static func centeredAttributedString(_ aText: NSAttributedString) -> NSAttributedString {
        let mText = NSMutableAttributedString.init(attributedString: aText)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        mText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: NSRange(location: 0, length: aText.length - 1))
        //            aText.attribute(.paragraphStyle, at: 0, longestEffectiveRange: NSRangePointer.(0, 10), in: NSMakeRange(0, 10))
        return mText.attributedSubstring(from: NSRange(location: 0, length: mText.length - 1))
    }
}

struct FontSize {
    static let large: CGFloat = 28
}

struct CactusFont {
    static let Large = UIFont.systemFont(ofSize: FontSize.large)
}
