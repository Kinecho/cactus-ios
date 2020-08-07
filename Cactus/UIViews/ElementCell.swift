//
//  ElementCell.swift
//  Cactus
//
//  Created by Neil Poulin on 4/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class ElementCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var logger = Logger("ElementCell")
    var margin: CGFloat = 20
    
    var isHeightCalculated: Bool = false
    var elementEntry: ElementEntry! {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateView() {
        self.imageView.image = self.elementEntry.image
        self.imageView.tintColor = self.elementEntry.element.color
        self.titleLabel.text = self.elementEntry.title
        self.descriptionLabel.text = self.elementEntry.description
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
