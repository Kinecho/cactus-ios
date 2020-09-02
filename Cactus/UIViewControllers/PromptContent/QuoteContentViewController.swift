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
    @IBOutlet weak var mainSackView: UIStackView!
    
    var lastCardButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view.
    }

    override func configureView() {
        guard self.isViewLoaded else {
            return
        }
        self.initTextView(self.quoteText)
        self.initTextView(self.authorNameTextView)
        self.initTextView(self.authorTitleTextView)
        
        if let quote = content.quote, let text = quote.getMarkdownText() {
            if let mdText = MarkdownUtil.centeredMarkdown(text, font: CactusFont.normal(24), color: CactusColor.textDefault) {
                self.quoteText.attributedText = mdText.preventOrphanedWords()
            }
            self.authorNameTextView.text = quote.authorName
            self.authorTitleTextView.text = quote.authorTitle
            
            ImageService.shared.setPhoto(self.avatarImageView, photo: quote.authorAvatar)
        } else {
            self.quoteText.text = nil
            self.authorTitleTextView.text = nil
            self.authorNameTextView.text = nil
        }
        
        self.lastCardButton?.removeFromSuperview()
        if let lastCardButton = self.getLastCardDoneButton() {            
            self.lastCardButton = lastCardButton
            self.mainSackView.addArrangedSubview(lastCardButton)
        }
        
        if let linkButton = self.createContentLink() {
            self.mainSackView.addArrangedSubview(linkButton)
        }
    }
}
