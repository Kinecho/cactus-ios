//
//  TextContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import MarkdownKit

class TextContentViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    var content: Content!
    var promptContent: PromptContent!
    
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
        
        if let textString = textString, !textString.isEmpty {
            let markdownParser = MarkdownParser(font: CactusFont.Large)
            self.text.attributedText = FormatUtils.centeredAttributedString(markdownParser.parse(textString))
        }
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
