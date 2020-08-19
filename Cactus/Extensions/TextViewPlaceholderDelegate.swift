//
//  TextViewPlaceholderDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 7/1/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit

class TextViewPlaceholderDelegate: NSObject, UITextViewDelegate {
    var placeholderText: String = ""
    var placeholderColor: UIColor = NamedColor.TextPlaceholder.uiColor
    var textView: UITextView
    
    convenience init(_ text: String, _ textView: UITextView) {
        self.init(text, CactusColor.placeholderText, textView)
    }
    
    init(_ placeholder: String, _ color: UIColor=CactusColor.placeholderText, _ textView: UITextView) {
        self.placeholderText = placeholder
        self.placeholderColor = color
        self.textView = textView
        super.init()
        textView.delegate = self
        self.initTextView(textView)
        
    }
    
    private func initTextView(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeholderText
            textView.textColor = self.placeholderColor
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == self.placeholderColor {
            textView.text = nil
            textView.textColor = CactusColor.textDefault
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeholderText
            textView.textColor = self.placeholderColor
        }
    }
    
    var text: String? {
        if self.textView.textColor == self.placeholderColor {
            return nil
        }
        return self.textView.text
    }
}
