//
//  UpgradeJournalFeedCollectionReusableView.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class UpgradeJournalFeedCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var upgradeButton: PrimaryButton!
    
    @IBInspectable var stackViewBackgroundColor: UIColor = CactusColor.magenta
    @IBInspectable var borderRadius: CGFloat = 0
    
    var addedBackground = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        
    }

    override func layoutSubviews() {
        self.titleLabel.font = CactusFont.bold(18)
        self.descriptionLabel.font = CactusFont.normal(18)
        
        if !addedBackground {
            let imageView = UIImageView(image: CactusImage.plusBg.getImage())
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.mainStackView.insertSubview(imageView, at: 0)
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.topAnchor.constraint(equalTo: self.mainStackView.topAnchor, constant: 0).isActive = true
//            imageView.bottomAnchor.constraint(equalTo: self.mainStackView.bottomAnchor, constant: 0).isActive = true
//            imageView.leadingAnchor.constraint(equalTo: self.mainStackView.leadingAnchor, constant: 0).isActive = true
//            imageView.trailingAnchor.constraint(equalTo: self.mainStackView.trailingAnchor, constant: 0).isActive = true
            self.addedBackground = true
        }
        
        super.layoutSubviews()
    }
}
