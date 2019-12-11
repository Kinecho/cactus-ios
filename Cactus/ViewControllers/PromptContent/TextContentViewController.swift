//
//  TextContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class TextContentViewController: PromptContentViewController {
    @IBOutlet weak var stackViewContainerBottomToImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackContainerBottomToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var elementImage: UIImageView!
    @IBOutlet weak var elementLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageViewAligned!
    @IBOutlet weak var elementStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTextView(self.text)
        self.configureView()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateConstraints()
    }
    
    func updateConstraints() {
        if self.content.backgroundImage?.isEmpty ?? true {
            self.stackViewContainerBottomToImageConstraint.isActive = false
            self.stackContainerBottomToSuperviewConstraint.isActive = true
        } else {
            self.stackContainerBottomToSuperviewConstraint.isActive = false
            self.stackViewContainerBottomToImageConstraint.isActive = true
        }
        
        if (self.content.showElementIcon ?? false), let element = self.promptContent.cactusElement {
            self.elementLabel.text = element.rawValue.uppercased()
            self.elementImage.image = element.getImage()
            
            self.elementStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.elementTapped)))
            
            self.elementStackView.isHidden = false
        } else {
            self.elementStackView.isHidden = true
        }
        
    }
    
    func configureView() {
        self.text.text = self.content.text
        var textString: String? = self.content.text_md
        if textString == nil || textString?.isEmpty ?? true {
            textString = self.content.text
        }
        
        if let mdText = MarkdownUtil.centeredMarkdown(textString?.preventOrphanedWords(), font: CactusFont.normal(24)) {
            self.text.attributedText = mdText
        } 

        self.backgroundImageView.setImageFile(self.content.backgroundImage)
        self.updateConstraints()
        
    }
    
    @objc func elementTapped() {
        guard let element = self.promptContent.cactusElement else {return}
        
        guard let contentVc = AppDelegate.shared.rootViewController.getScreen(ScreenID.elementsPageView) as? CactusElementPageViewController else {return}
        contentVc.initialElement = element
        
        let modalVc = ModalViewController()
        modalVc.contentVc = contentVc
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
        self.present(modalVc, animated: true, completion: nil)
    }
}
