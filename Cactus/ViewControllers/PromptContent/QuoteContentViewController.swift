//
//  QuoteContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/14/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class QuoteContentViewController: UIViewController {
    @IBOutlet weak var quoteText: UITextView!
    @IBOutlet weak var authorNameText: UILabel!
    @IBOutlet weak var authorTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var content: Content!
    var promptContent: PromptContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        // Do any additional setup after loading the view.
    }

    func configureView() {
        if let quote = content.quote, let textString = quote.text {
            if let mdText = MarkdownUtil.centeredMarkdown(textString, font: CactusFont.large) {
                self.quoteText.attributedText = mdText
            }
            self.authorNameText.text = quote.authorName
            self.authorTitle.text = quote.authorTitle
            
            
            ImageService.shared.setPhoto(self.avatarImageView, photo: quote.authorAvatar)
            
        } else {
            self.quoteText.text = nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
/Users/neilpoulin/repos/kinecho/cactus-ios/Cactus/Cactus/ViewControllers/AppMainViewController.swift    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   /Users/neilpoulin/repos/kinecho/cactus-ios/Cactus/Cactus/ViewControllers/AppMainViewController.swift     // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
