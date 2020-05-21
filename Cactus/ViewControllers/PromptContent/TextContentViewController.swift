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
    @IBOutlet weak var elementImageContainerView: RoundedView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var textTouchDelegate: UIGestureRecognizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTextView(self.text)
        self.configureView()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateConstraints()
    }
    
    override func memberDidSet(updated: CactusMember?, previous: CactusMember?) {
        super.memberDidSet(updated: updated, previous: previous)
        self.configureView()
    }
    
    override func reflectionResponseDidSet(updated: ReflectionResponse?, previous: ReflectionResponse?) {
        super.reflectionResponseDidSet(updated: updated, previous: previous)
        self.configureView()
    }
    
    func updateConstraints() {
        if self.content.backgroundImage?.isEmpty ?? true {
            self.stackViewContainerBottomToImageConstraint.isActive = false
            self.stackContainerBottomToSuperviewConstraint.isActive = true
        } else {
            self.stackContainerBottomToSuperviewConstraint.isActive = false
            self.stackViewContainerBottomToImageConstraint.isActive = true
        }
        
        if self.content.showElementIcon == true {
            self.elementStackView.isHidden = false
        } else {
            self.elementStackView.isHidden = true
        }
        
    }
    
    func configureView() {
        guard self.isViewLoaded else {
            return
        }
        self.text.text = self.content.text
//        var textString: String? = self.content.text_md
//        if textString == nil || textString?.isEmpty ?? true {
//            textString = self.content.text
//        }
        let coreValue = self.reflectionResponse?.coreValue
        let member = CactusMemberService.sharedInstance.currentMember
        let textString = self.content.getDisplayText(member: member, preferredIndex: self.promptContent.preferredCoreValueIndex, coreValue: coreValue)
        
        if let mdText = MarkdownUtil.centeredMarkdown(textString?.preventOrphanedWords(), font: CactusFont.normal(24)) {
            self.text.attributedText = mdText.preventOrphanedWords()
        }
        
        self.text.tintColor = CactusColor.darkGreen

        self.backgroundImageView.setImageFile(self.content.backgroundImage)
        
         if (self.content.showElementIcon ?? false), let element = self.promptContent.cactusElement {
            self.elementLabel.text = element.rawValue.uppercased()
            self.elementImage.image = element.getImage()
            self.elementImageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.elementTapped)))
            self.elementLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.elementTapped)))
        }
        
        if let contentButton = self.createContentLink() {
            self.mainStackView.addArrangedSubview(contentButton)
        }
        
        if let actionButton = self.createActionButton() {
            self.mainStackView.addArrangedSubview(actionButton)
        }
        
        self.labelLabel.text = self.content.label
        self.labelLabel.isHidden = isBlank(self.content.label)
        
        self.titleLabel.text = self.content.title
        self.titleLabel.isHidden = isBlank(self.content.title)
        
        self.updateConstraints()
    }
    
    @objc func elementTapped() {
        guard let element = self.promptContent.cactusElement else {return}
        
        guard let contentVc = ScreenID.elementsPageView.getViewController() as? CactusElementPageViewController else {return}
        contentVc.initialElement = element
        
        let modalVc = ModalViewController()
        modalVc.contentVc = contentVc
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
        self.present(modalVc, animated: true, completion: nil)
    }
}
