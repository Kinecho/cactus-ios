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

public class MarkdownUtil {
    
    static func centered(_ aText: NSAttributedString?) -> NSAttributedString? {
        guard let aText = aText else {
            return nil
        }
        
        let mText = NSMutableAttributedString.init(attributedString: aText)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        mText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: NSRange(location: 0, length: aText.length - 1))
        //            aText.attribute(.paragraphStyle, at: 0, longestEffectiveRange: NSRangePointer.(0, 10), in: NSMakeRange(0, 10))
        return mText.attributedSubstring(from: NSRange(location: 0, length: mText.length - 1))
    }
    
    static func centeredMarkdown(_ input: String?, font: UIFont = CactusFont.normal) -> NSAttributedString? {
        guard let md = MarkdownUtil.toMarkdown(input, font: font)  else {
            return nil
        }        
        return MarkdownUtil.centered(md)
    }
    
    static func toMarkdown(_ input: String?, font: UIFont = CactusFont.normal) -> NSAttributedString? {
        guard let input = input, !input.isEmpty else {
            return nil
        }
        
        let markdownParser = MarkdownParser(font: font)
        return markdownParser.parse(input)
    }
}
