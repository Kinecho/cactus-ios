//
//  QuoteContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/14/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class QuoteContentViewController: PromptContentViewController {
    @IBOutlet weak var quoteText: UITextView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorNameTextView: UITextView!
    @IBOutlet weak var authorTitleTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view.
    }

    func configureView() {
        self.initTextView(self.quoteText)
        self.initTextView(self.authorNameTextView)
        self.initTextView(self.authorTitleTextView)
        
        if let quote = content.quote, let textString = quote.text, let wrappedText = FormatUtils.wrapInDoubleQuotes(input: textString.preventOrphanedWords()) {
            if let mdText = MarkdownUtil.centeredMarkdown(wrappedText, font: CactusFont.normal(24), color: CactusColor.textDefault) {
                self.quoteText.attributedText = mdText
            }
            self.authorNameTextView.text = quote.authorName
            self.authorTitleTextView.text = quote.authorTitle
            
            ImageService.shared.setPhoto(self.avatarImageView, photo: quote.authorAvatar)
        } else {
            self.quoteText.text = nil
            self.authorTitleTextView.text = nil
            self.authorNameTextView.text = nil
        }
    }
}
