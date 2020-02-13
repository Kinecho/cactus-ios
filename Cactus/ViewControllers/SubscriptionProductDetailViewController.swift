//
//  SubscriptionProductDetailViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionProductDetailViewController: UIViewController {
    var product: SubscriptionProductEntry!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var featureStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureText()
    }
        
    func getPriceLabel() -> String? {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = self.product.skProduct.priceLocale
        guard let amount = currencyFormatter.string(from: self.product.skProduct.price) else {
            return nil
        }
        let period = self.product.subscriptionProduct.billingPeriod.rawValue
        return "\(amount)/\(period)"
    }
    
    func configureText() {
        self.productNameLabel.text = self.product.subscriptionProduct.displayName
        self.priceLabel.text = getPriceLabel()
        self.configureFeatures()
    }
    
    func configureFeatures() {
        
    }
    
    @IBAction func purchaseTapped(_ sender: Any) {
        let payment = SKMutablePayment(product: self.product.skProduct)
        SKPaymentQueue.default().add(payment)

    }
    
}
