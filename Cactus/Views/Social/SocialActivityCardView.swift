//
//  SocialActivityCardView.swift
//  Cactus
//
//  Created by Neil Poulin on 1/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class SocialActivityCardView: UIStackView {
    @IBOutlet weak var avatarImageView: CircleImageView!
    @IBOutlet weak var dateTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var view: UIView!
    
    @IBInspectable var cornerRadius: CGFloat = 12
    
    @IBInspectable var memberName: String? {
        didSet {
            self.configureContentText()
        }
    }
    @IBInspectable var question: String? {
        didSet {
            self.configureContentText()
        }
    }
    
    @IBInspectable
    var date: Date? {
        didSet {
            self.dateTextView?.text = formatDuaration(self.date)
        }
    }
    
    @IBInspectable
    var dateText: String? {
        get {
            self.dateTextView?.text
        }
        set {
            self.dateTextView?.text = newValue
        }
    }
    
    @IBInspectable
    var image: UIImage? {
        get {
            self.avatarImageView?.image
        }
        set {
            self.avatarImageView?.image = newValue
        }
    }
 
    func configureContentText() {
        let name = self.memberName ?? ""
        let question = (self.question ?? "").preventOrphanedWords()
        
        let plainString = "\(name) reflected on \(question)"
        
        let attributedText = NSAttributedString(string: plainString)
            .withFont(CactusFont.normal)
            .withBold(forSubstring: name)
            .withBold(forSubstring: question)
            .withColor(CactusColor.textDefault)
        
        self.contentTextView.attributedText = attributedText
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.cornerRadius
        self.view.layer.cornerRadius = self.cornerRadius
        self.addShadows()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView() {
        let view = loadViewFromNib()
        distribution = .fill
        alignment = .fill
    
        self.addArrangedSubview(view)
        self.view = view
        self.configure()
    }
    
    func configure() {
        self.backgroundColor = CactusColor.noteBackground
        self.view.backgroundColor = CactusColor.noteBackground
        self.view.clipsToBounds = true
        
        self.contentTextView.textContainerInset = UIEdgeInsets.zero
        self.dateTextView.textContainerInset = UIEdgeInsets.zero
    }

}
