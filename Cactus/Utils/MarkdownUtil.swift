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
    static func centered(_ aText: NSAttributedString?, color: UIColor?=CactusColor.textDefault) -> NSAttributedString? {
        guard let aText = aText else {
            return nil
        }
        
        let mText = NSMutableAttributedString.init(attributedString: aText)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let range = NSRange(location: 0, length: aText.length)
        mText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: range)
        
        let aString = mText.attributedSubstring(from: NSRange(location: 0, length: mText.length))
        if let color = color {
            return aString.withColor(color)
        } else {
            return aString
        }
    }
    
    static func centeredMarkdown(_ input: String?, font: UIFont = CactusFont.normal, color: UIColor?=CactusColor.textDefault) -> NSAttributedString? {
        guard let md = MarkdownUtil.toMarkdown(input, font: font)  else {
            return nil
        }        
        let aString = MarkdownUtil.centered(md)
        if let color = color {
            return aString?.withColor(color)
        } else {
            return aString
        }
        
    }
    
    static func toMarkdown(_ input: String?, font: UIFont = CactusFont.normal, color: UIColor? = CactusColor.textDefault) -> NSAttributedString? {
        guard let input = input, !input.isEmpty else {
            return nil
        }
        
        let markdownParser = MarkdownParser(font: font, color: color ?? CactusColor.textDefault)
        markdownParser.link.color = CactusColor.green
        markdownParser.automaticLink.color = CactusColor.green
//        markdownParser.automaticLink.att
//        markdownParser.link.
        let aString = markdownParser.parse(input)
        if let color = color {
            return aString.withColor(color)
        } else {
            return aString
        }
    }
}
