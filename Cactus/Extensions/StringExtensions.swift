//
//  StringExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 11/1/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func toAttributedString() -> NSAttributedString {
        return self.attributedSubstring(from: self.fullRange)
    }
}

extension NSAttributedString {
    
    var fullRange: NSRange { return NSRange(location: 0, length: self.length) }
    
    func toMutable() -> NSMutableAttributedString {
        let mText = NSMutableAttributedString.init(attributedString: self)
        return mText
    }
    
    func withColor(_ color: UIColor) -> NSAttributedString {
//        let range = NSRange(location: 0, length: self.length)
//        let mText = NSMutableAttributedString.init(attributedString: self)
//        mText.addAttributes([NSAttributedString.Key.foregroundColor: color], range: self.fullRange)
//        return mText.attributedSubstring(from: NSRange(location: 0, length: mText.length))
        
        return self.withAttributes([NSAttributedString.Key.foregroundColor: color])
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        return self.withAttributes([NSAttributedString.Key.paragraphStyle: paragraph])
    }
    
    func withAttributes(_ attributes: [NSAttributedString.Key : Any], range: NSRange?=nil) -> NSAttributedString {
        let range = range ?? self.fullRange
        let mText = self.toMutable()
        mText.addAttributes(attributes, range: range)
        return mText.toAttributedString()
    }
}
