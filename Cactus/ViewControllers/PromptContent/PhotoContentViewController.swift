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
    var originalImageView: UIImageView?
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
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
//        self.imageView.isHidden = true
        self.originalImageView = UIImageView()
        self.originalImageView?.setImageFile(photo)
        self.imageView.setImageFile(photo)
//        self.imageView.did
    }
    
    // MARK: - Dark Mode Support
    private func updateImageForCurrentTraitCollection() {
        if traitCollection.userInterfaceStyle == .dark {
            self.imageView.image = originalImageView?.image?.invertedColors()
        } else {
            self.imageView.image = originalImageView?.image
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateImageForCurrentTraitCollection()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
