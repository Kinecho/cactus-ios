//
//  ManageSubscriptionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import StoreKit
class ManageSubscriptionViewController: UIViewController {

    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var upgradeButton: PrimaryButton!
    let logger = Logger("ManageSubscriptionViewContrller")
    var productRequest: SKProductsRequest?
    var availableProducts: [SKProduct] = []
    var subscriptionProducts: [SubscriptionProduct] = []
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isAuthorizedForPayments {
            self.fetchProducts()
        }
        // Do any additional setup after loading the view.
    }
    
    func fetchProducts() {
        SubscriptionProductService.sharedInstance.getAll { result in
            if let error = result.error {
                self.logger.error("Failed to ofetch subscription products", error)
                return
            }
            self.subscriptionProducts = result.results ?? []
            let appleIds: [String] = self.subscriptionProducts.compactMap { (p) -> String? in
                p.appleProductId
            }
            self.fetchAppleProducts(matchingIdentifiers: appleIds)
        }
    }
    
    fileprivate func fetchAppleProducts(matchingIdentifiers identifiers: [String]) {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)

        // Initialize the product request with the above identifiers.
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self

        // Send the request to the App Store.
        productRequest?.start()
    }
    
    @IBAction func upgradeTapped(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ManageSubscriptionViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.logger.info("Product request did return")
        
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            self.logger.info("Found \(response.products.count): \(response.products)")
            availableProducts = response.products
            
//            storeResponse.append(Section(type: .availableProducts, elements: availableProducts))
        }

        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            self.logger.warn("Fouond invalid products: \(response.invalidProductIdentifiers)")
//            invalidProductIdentifiers = response.invalidProductIdentifiers
//            storeResponse.append(Section(type: .invalidProductIdentifiers, elements: invalidProductIdentifiers))
        }
    }
}
