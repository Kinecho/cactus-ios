//
//  PrivingFeatureItemViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class PricingFeatureItemViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var feature: PricingFeature! {
        didSet {
            self.configureFeature()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureFeature()
    }
    
    func configureFeature() {
        guard self.isViewLoaded else {
            return
        }
        DispatchQueue.main.async {
            self.titleLabel.attributedText = MarkdownUtil.toMarkdown(self.feature.titleMarkdown, font: CactusFont.bold(20))
            self.descriptionLabel.attributedText = MarkdownUtil.toMarkdown(self.feature.descriptionMarkdown)
            self.iconImageView.image = self.feature.icon?.image
            self.view.setNeedsLayout()
        }
    }
}
