//
//  TextContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class TextContentViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    var content: Content!
    var promptContent: PromptContent!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        // Do any additional setup after loading the view.
    }

    func configureView() {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
