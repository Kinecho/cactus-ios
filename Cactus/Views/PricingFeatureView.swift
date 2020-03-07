//
//  PricingFeatureView.swift
//  Cactus
//
//  Created by Neil Poulin on 3/6/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class PricingFeatureView: UIView {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var copyStackView: UIStackView!
    
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    
    @IBInspectable var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = self.iconImage
        }
    }
    
    var icon: IconType? {
        didSet {
            self.iconImage = self.icon?.image
        }
    }
    
    @IBInspectable var iconDiameter: CGFloat = 30 {
        didSet {
            DispatchQueue.main.async {
                self.iconWidthConstraint.constant = self.iconDiameter
                self.iconHeightConstraint.constant = self.iconDiameter
                self.setNeedsLayout()
            }
        }
    }
    
    var view: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        self.view = view
        self.view.backgroundColor = .clear
        self.view.clipsToBounds = true
        self.addSubview(view)
        self.configure()
        
    }
    
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
}
