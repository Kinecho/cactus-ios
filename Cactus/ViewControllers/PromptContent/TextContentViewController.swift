//
//  TextContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class TextContentViewController: PromptContentViewController {

    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var backgroundImageView: UIImageViewAligned!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        // Do any additional setup after loading the view.
    }

    func configureView() {
        self.initTextView(self.text)
        
        self.text.text = self.content.text
        var textString: String? = self.content.text_md
        if textString == nil || textString?.isEmpty ?? true {
            textString = self.content.text
        }
        
        if let mdText = MarkdownUtil.centeredMarkdown(textString, font: CactusFont.large) {
            self.text.attributedText = mdText
        }

        self.backgroundImageView.setImageFile(self.content.backgroundImage)
    }
}
