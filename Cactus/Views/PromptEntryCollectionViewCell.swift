//
//  PromptEntryCollectionViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 4/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class PromptEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var responseStackView: UIStackView!
    @IBOutlet weak var responseHighlightView: UIView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var data: PromptContentData? {
        didSet {
            self.updateView()
        }
    }
    
    var margin: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
        self.contentView.clipsToBounds = true
        self.responseHighlightView.layer.cornerRadius = self.responseHighlightView.bounds.width
        self.responseHighlightView.clipsToBounds = true
        self.responseTextView.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20)
        self.responseTextView.contentInset = UIEdgeInsets.zero
        self.responseTextView.isScrollEnabled = false
        self.responseTextView.textContainer.lineFragmentPadding = 0

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10.0)
        self.layer.shadowRadius = self.layer.cornerRadius
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.responseHighlightView.transform = CGAffineTransform.identity.translatedBy(x: -1 * self.responseHighlightView.bounds.width / 2, y: 0)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func updateView() {
        guard let data = self.data else {
            self.questionLabel.text = "Loading"
            self.imageView.image = nil
            self.imageView.isHidden = true
            self.activityIndicator.startAnimating()
            return
        }
        self.activityIndicator.stopAnimating()
        
        if let responseText = data.responseData.responses.first?.content.text {
            self.responseStackView.isHidden = false
            self.responseTextView.text = responseText
            self.dateLabel.text = FormatUtils.formatDate(data.responseData.responses.first?.reflectionDates?.last ?? data.responseData.responses.first?.updatedAt)
        } else {
            self.responseStackView.isHidden = true
        }
        
        self.imageView.setImageFile(data.promptContent.getMainImageFile())
        self.questionLabel.attributedText = MarkdownUtil.toMarkdown(data.promptContent.getQuestionMarkdown(), font: CactusFont.bold(22))
    }
    
    func setWidth(_ width: CGFloat) {
        if self.widthConstraint.constant == width {
            return
        }
        self.widthConstraint.constant = width
        self.setNeedsLayout()
    }
    
    //TODO: Removed while testing layout updates to the collection view
    //from article: The default implementation of this method simply applies any autolayout constraints to the configured view. If the size is different, it will return a preferred set of attributes.
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height) + 1
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
    
}
