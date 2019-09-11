//
//  TextContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Down
import MarkdownKit

class TextContentViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    var content: Content!;
    var promptContent: PromptContent!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        // Do any additional setup after loading the view.
    }

    func configureView(){
        self.text.text = self.content.text
        if let textString = self.content.text {
//            let down = Down(markdownString: textString)
//            if let attributedText =  try? down.toAttributedString(.default, stylesheet: "{font-size: 32pt;}") {
//                self.text.attributedText = attributedText
//            }
            
            let markdownParser = MarkdownParser(font: CactusFont.Large);
//            markdownParser.font.paragr
            
//            let aText =
//            let mText = NSMutableAttributedString.init(attributedString: aText)
//            let paragraph = NSMutableParagraphStyle()
//            paragraph.alignment = .center
//            mText.addAttributes([NSAttributedString.Key.paragraphStyle : paragraph], range: NSMakeRange(0, aText.length - 1))
//            aText.attribute(.paragraphStyle, at: 0, longestEffectiveRange: NSRangePointer.(0, 10), in: NSMakeRange(0, 10))
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
