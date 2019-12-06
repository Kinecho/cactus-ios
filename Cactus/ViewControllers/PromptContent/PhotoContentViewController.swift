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
    @IBOutlet weak var imageView: UIImageView!
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
        
        if let mdText = MarkdownUtil.centeredMarkdown(content.text, font: CactusFont.normal(24)) {
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
