//
//  PhotoContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Cloudinary
class PhotoContentViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    var content: Content!
    var promptContent: PromptContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureView()
    }

    func configureView() {
        if let photo = content.photo {
            self.configurePhoto(photo)
        } else {
            self.imageView.isHidden = true
        }
        
        if let mdText = MarkdownUtil.centeredMarkdown(content.text, font: CactusFont.large) {
            self.textView.attributedText = mdText
            self.textView.isHidden = false
        } else {
            self.textView.isHidden = true
        }
    }
    
    func configurePhoto(_ photo: ImageFile) {
//        self.imageView.isHidden = true
        self.imageView.setImageFile(photo)
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
