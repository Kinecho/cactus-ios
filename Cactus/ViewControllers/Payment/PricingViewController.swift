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
    let logger = Logger("PricingViewController")
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.closeButton.isHidden = !self.isBeingPresented
        
        let plan1 = SubscriptionPlanOptionView()
        plan1.priceLabel.text = "$29"
        plan1.titleLabel.text = "Annual"
        plan1.periodLabel.text = "year"
        
        let plan2 = SubscriptionPlanOptionView()
        plan2.priceLabel.text = "$1.99"
        plan2.titleLabel.text = "Weekly"
        plan2.periodLabel.text = "week"
        
        let plan3 = SubscriptionPlanOptionView()
        plan3.priceLabel.text = "$4.99"
        plan3.titleLabel.text = "Monthly"
        plan3.periodLabel.text = "month"
        plan3.selected = true
        
        self.planStackView.addArrangedSubview(plan2)
        self.planStackView.addArrangedSubview(plan3)
        self.planStackView.addArrangedSubview(plan1)
        
        self.configurePlanTapGesture(planView: plan1)
        self.configurePlanTapGesture(planView: plan2)
        self.configurePlanTapGesture(planView: plan3)
        
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
