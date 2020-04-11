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
    @IBOutlet weak var label: UILabel!
    
    var margin: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
                
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
        self.contentView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1 * margin/2, height: 10.0)
        self.layer.shadowRadius = self.layer.cornerRadius
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
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
