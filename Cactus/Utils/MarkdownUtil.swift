//
//  MarkdownUtil.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import MarkdownKit
import UIKit


extension NSAttributedString {
    func toColor(_ color: UIColor) -> NSAttributedString {
        let range = NSRange(location: 0, length: self.length)
        let mText = NSMutableAttributedString.init(attributedString: self)
        mText.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
        return mText.attributedSubstring(from: NSRange(location: 0, length: mText.length))
    }
}

public class MarkdownUtil {
    
    static func colored(_ aText: NSAttributedString?, color: UIColor) -> NSAttributedString? {
        guard let aText = aText else {
            return nil
        }
        let range = NSRange(location: 0, length: aText.length)
        let mText = NSMutableAttributedString.init(attributedString: aText)
        mText.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
        return mText.attributedSubstring(from: NSRange(location: 0, length: mText.length))
    }
    
    static func centered(_ aText: NSAttributedString?, color: UIColor?=CactusColor.darkestGreen) -> NSAttributedString? {
        guard let aText = aText else {
            return nil
        }
        
        let mText = NSMutableAttributedString.init(attributedString: aText)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let range = NSRange(location: 0, length: aText.length)
        mText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: range)
        //            aText.attribute(.paragraphStyle, at: 0, longestEffectiveRange: NSRangePointer.(0, 10), in: NSMakeRange(0, 10))
        if let color = color {
            mText.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
        }
        
        let aString = mText.attributedSubstring(from: NSRange(location: 0, length: mText.length))
        if let color = color {
            return colored(aString, color: color)
        } else {
            return aString
        }
    }
    
    static func centeredMarkdown(_ input: String?, font: UIFont = CactusFont.normal, color: UIColor?=CactusColor.darkestGreen) -> NSAttributedString? {
        guard let md = MarkdownUtil.toMarkdown(input, font: font)  else {
            return nil
        }        
        let aString = MarkdownUtil.centered(md)
        if let color = color {
            return colored(aString, color: color)
        } else {
            return aString
        }
        
    }
    
    static func toMarkdown(_ input: String?, font: UIFont = CactusFont.normal, color: UIColor? = CactusColor.darkestGreen) -> NSAttributedString? {
        guard let input = input, !input.isEmpty else {
            return nil
        }
        
        let markdownParser = MarkdownParser(font: font)
        let aString = markdownParser.parse(input)
        if let color = color {
            return colored(aString, color: color)
        } else {
            return aString
        }
    }
}
