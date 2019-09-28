//
//  JournalEntrySkeletonViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import SkeletonView

class JournalEntrySkeletonViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseContainerView: UIView!
    @IBOutlet weak var responseBorderView: UIView!
    @IBOutlet weak var responseLabel: UILabel!
    
    let radius = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.startSkeleton()
    }
    
    func configureView() {
        SkeletonAppearance.default.multilineCornerRadius = self.radius
        self.view.layer.cornerRadius = 12
        self.view.clipsToBounds = true
        self.responseBorderView.layer.cornerRadius = 6
    }

    func startSkeleton() {
        self.questionLabel.showAnimatedGradientSkeleton()
        self.questionLabel.linesCornerRadius = self.radius
        self.questionLabel.clipsToBounds = true
        self.questionLabel.layer.cornerRadius = CGFloat(self.radius)
        
        self.dateLabel.showAnimatedGradientSkeleton()
        self.dateLabel.linesCornerRadius = self.radius
        self.dateLabel.clipsToBounds = true
        self.dateLabel.layer.cornerRadius = CGFloat(self.radius)
        
        self.responseLabel.showAnimatedGradientSkeleton()
        
        self.responseLabel.linesCornerRadius = self.radius
        self.responseLabel.isHidden = true
        self.responseLabel.hideSkeleton()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.responseLabel.showAnimatedGradientSkeleton()
            self.responseLabel.isHidden = false
        }
    }
    
}
