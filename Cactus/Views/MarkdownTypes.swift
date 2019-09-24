//
//  MarkdownTypes.swift
//  Cactus
//
//  Created by Neil Poulin on 9/11/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import MarkdownKit

class CenteredText: MarkdownStyle {
    var font: MarkdownFont?
    
    var color: MarkdownColor?
    
    var attributes: [NSAttributedString.Key: AnyObject] = [
        NSAttributedString.Key.paragraphStyle: getParagraphStyle()
    ]
    
    static func getParagraphStyle() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
    }
}
