//
//  TextViewUrlTouchGestureDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 2/5/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit

class TextViewUrlTouchGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    let textView: UITextView
    let logger: Logger
    var onLinkTapped: (URL) -> Void
    
    init(textView: UITextView, openLinks: Bool = true) {
        self.textView = textView
        let logger = Logger("TextViewUrlTouchGestureDelegate")
        self.logger = logger
        if openLinks {
            self.onLinkTapped = { url in
                logger.info("Link tapped. Opening in browser")
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.onLinkTapped = {logger.info("Link tapped: \($0)")}
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.logger.info("Gesture should begin")
        guard let gesture = gestureRecognizer as? UITapGestureRecognizer else {
            return true
        }

        let location = gesture.location(in: textView)
        
        guard let closest = textView.closestPosition(to: location),
            let startPosition = textView.position(from: closest, offset: -1),
            let endPosition = textView.position(from: closest, offset: 1) else {
            return false
        }

        guard let textRange = textView.textRange(from: startPosition, to: endPosition) else {
            return false
        }
        let startOffset = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let endOffset = textView.offset(from: textView.beginningOfDocument, to: textRange.end)
        let range = NSRange(location: startOffset, length: endOffset - startOffset)

        guard range.location != NSNotFound, range.length != 0 else {
            return false
        }

        guard let linkAttribute = textView.attributedText.attributedSubstring(from: range).attribute(.link, at: 0, effectiveRange: nil) else {
            return false
        }
        
        guard let linkString = String(describing: linkAttribute) as? String,
            let url = URL(string: linkString) else {
            return false
        }
                        
        guard self.textView.delegate?.textView?(textView, shouldInteractWith: url, in: range, interaction: .invokeDefaultAction) ?? true else {
            return false
        }

        onLinkTapped(url)

        return true
    }
}
