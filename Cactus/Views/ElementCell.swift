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
        
//        self.widthConstraint.constant = self.getWidth()
        
        self.contentView.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
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
    
    func updateView() {
        self.imageView.image = self.elementEntry.image
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
    
}