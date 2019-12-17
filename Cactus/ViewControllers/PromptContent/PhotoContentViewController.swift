//
//  PhotoContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Cloudinary
class PhotoContentViewController: PromptContentViewController {
    @IBOutlet weak var imageView: InvertableImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        configureView()
    }

    func configureView() {
        self.initTextView(self.textView)
        if let photo = content.photo {
            self.configurePhoto(photo)
        } else {
            self.imageView.isHidden = true
        }
        
        var textString = content.text_md?.preventOrphanedWords()
        if isBlank(textString) {
            textString = content.text?.preventOrphanedWords()
        }
        if let mdText = MarkdownUtil.centeredMarkdown(textString, font: CactusFont.normal(24)) {
            self.textView.attributedText = mdText
            self.textView.isHidden = false
        } else {
            self.textView.isHidden = true
        }
    }
    
    func configurePhoto(_ photo: ImageFile) {
        self.imageView.setImageFile(photo)
    }
}
