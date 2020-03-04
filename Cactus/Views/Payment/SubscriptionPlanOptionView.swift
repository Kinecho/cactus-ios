//
//  SubscriptionPlanOptionView.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class SubscriptionPlanOptionView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var dividerLabel: UILabel!
    @IBOutlet weak var savingsCopyLabel: UILabel!
    
    @IBOutlet weak var savingsContainerView: UIView!
    var subscriptionProduct: SubscriptionProduct? {
        didSet {
            self.configureProduct()
        }
    }
    
    var selectedTextColor: UIColor = CactusColor.darkText
    var defaultTextColor: UIColor = CactusColor.white
    var savingsBackgroundColor: UIColor = CactusColor.royal
    
    var selected: Bool = false {
        didSet {
            self.setNeedsLayout()
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
        self.view.clipsToBounds = true
        self.addSubview(view)
        self.configure()
                
    }
    
    func configureProduct() {
        guard let product = self.subscriptionProduct else {
            self.isHidden = true
            return
        }
        
        self.titleLabel.text = product.billingPeriod.productTitle?.uppercased()
        self.priceLabel.text = product.isFree ? "Free" : formatPriceCents(product.priceCentsUsd)
        
        self.periodLabel.text = "per \(product.billingPeriod.displayName ?? "")"
        self.periodLabel.isHidden = product.isFree
        self.dividerLabel.isHidden = true
        
        if let savingsCopy = product.savingsCopy {
            self.savingsCopyLabel.text = savingsCopy.uppercased()
            self.savingsContainerView.isHidden = false
            
        } else {
            self.savingsContainerView.isHidden = true
        }
        
        self.isHidden = false
    }
    
    func configure() {
        self.backgroundColor = .clear
        self.view.backgroundColor = .clear
        self.view.layer.borderColor = CactusColor.white.withAlphaComponent(0.6).cgColor
        self.view.layer.borderWidth = CGFloat(1)
        self.view.layer.cornerRadius = CGFloat(12)
        self.savingsContainerView.backgroundColor = self.savingsBackgroundColor
        self.savingsCopyLabel.textColor = CactusColor.white
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.selected {
            self.view.backgroundColor = CactusColor.white
            self.setTextColor(self.selectedTextColor)
            self.view.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.view.backgroundColor = .clear
            self.setTextColor(self.defaultTextColor)
            self.view.layer.borderColor = CactusColor.white.withAlphaComponent(0.6).cgColor
        }
    }
    
    func setTextColor(_ color: UIColor) {
        self.titleLabel.textColor = color
        self.priceLabel.textColor = color
        self.periodLabel.textColor = color
        self.dividerLabel.textColor = color
    }
}
