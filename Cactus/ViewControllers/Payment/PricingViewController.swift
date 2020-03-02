//
//  PricingViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class PricingViewController: UIViewController {
    
    @IBOutlet weak var planStackView: UIStackView!
    @IBOutlet weak var footerStackView: UIStackView!
    
    @IBOutlet weak var footerDescriptionLabel: UILabel!
    @IBOutlet weak var footerIcon: UIImageView!
    @IBOutlet weak var continueButton: PrimaryButton!
    
    let logger = Logger("PricingViewController")
    var productsLoaded = false
    var productGroupEntryMap: SubscriptionProductGroupEntryMap? {
        didSet {
            DispatchQueue.main.async {
                self.configureProductsView()
            }
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton.isHidden = !self.isBeingPresented
        
        self.loadSubscriptionProducts()
        
    }
    
    func loadSubscriptionProducts() {
        SubscriptionService.sharedInstance.getSubscriptionProductGroupEntryMap { (entryMap) in
            self.productGroupEntryMap = entryMap
        }
    }
    
    func configureProductsView() {
        guard let groupEntry = self.productGroupEntryMap?[SubscriptionTier.PLUS] else {
            self.planStackView.arrangedSubviews.forEach { (planView) in
                self.planStackView.removeArrangedSubview(planView)
            }
            return
        }
        if let footer = groupEntry.productGroup?.footer {
            self.footerDescriptionLabel.attributedText = MarkdownUtil.toMarkdown(footer.textMarkdown)
            self.footerIcon.image = footer.icon?.image
            self.footerIcon.isHidden = footer.icon?.image == nil
            self.footerStackView.isHidden = false
        } else {
            self.footerStackView.isHidden = true
        }
        
        groupEntry.products.forEach { (product) in
            let planView = SubscriptionPlanOptionView()
            planView.subscriptionProduct = product
            self.configurePlanTapGesture(planView: planView)
            if product.billingPeriod == groupEntry.defaultSelectedPeriod {
                planView.selected = true
            }
            self.planStackView.addArrangedSubview(planView)
        }
        
        self.planStackView.isHidden = false
    }
    
    func configurePlanTapGesture(planView: SubscriptionPlanOptionView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.planSelected(sender:)))
        planView.addGestureRecognizer(tapGesture)
    }
    
    @objc func planSelected(sender: UITapGestureRecognizer) {
        guard let planView = sender.view as? SubscriptionPlanOptionView else {
            return
        }
        self.logger.info("Plan selected \(planView.titleLabel.text ?? "unknown")")
        
        self.planStackView.subviews.forEach { (pv) in
            guard let p = pv as? SubscriptionPlanOptionView else {
                return
            }
            p.selected = false
        }
        
        planView.selected = true
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
