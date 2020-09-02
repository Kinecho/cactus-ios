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
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
    }
    
    func configureFeature() {
        guard self.isViewLoaded else {
            return
        }
        DispatchQueue.main.async {
            self.titleLabel.attributedText = MarkdownUtil.toMarkdown(self.feature.titleMarkdown, font: CactusFont.bold(20))?.preventOrphanedWords()
            self.descriptionLabel.attributedText = MarkdownUtil.toMarkdown(self.feature.descriptionMarkdown?.preventOrphanedWords())?.preventOrphanedWords()
            self.iconImageView.image = Icon.getImage(self.feature.icon)
            self.view.setNeedsLayout()
        }
    }
}
