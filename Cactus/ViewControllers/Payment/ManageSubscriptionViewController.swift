//
//  ManageSubscriptionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
//import StoreKit
class ManageSubscriptionViewController: UIViewController {

    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var allOptionsButton: UIButton!
    @IBOutlet weak var cactusPlusButton: PrimaryButton!
    @IBOutlet weak var featureStackView: UIStackView!
    
    let logger = Logger("ManageSubscriptionViewContrller")
//    var productRequest: SKProductsRequest?
//    var availableProducts: [SKProduct] = []
    var subscriptionProducts: [SubscriptionProduct] = []
    var productEntries: [SubscriptionProductEntry] {
//        let entries = availableProducts.compactMap { (skProduct) -> SubscriptionProductEntry? in
//            let appleId = skProduct.productIdentifier
//            let subProduct = subscriptionProducts.first { $0.appleProductId == appleId }
//            guard let subscriptionProduct = subProduct else {
//                return nil
//            }
//
//            return SubscriptionProductEntry(subscriptionProduct: subscriptionProduct, skProduct: skProduct)
//        }
        
//        return entries
        return []
    }
    
    var isAuthorizedForPayments: Bool {
//        return SKPaymentQueue.canMakePayments()
        return false
    }
    
    var memberObserver: Unsubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.memberObserver = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, _) in
            if let error = error {
                self.logger.error("Failed to fetch cactus member", error)
                return
            }
            self.setupCurrentMembership(member: member)
        }
//        self.setupCurrentMembership()
        if self.isAuthorizedForPayments {
            self.fetchProducts()
        }
        // Do any additional setup after loading the view.
    }
    
    func setupCurrentMembership(member: CactusMember?) {
        guard let member = member else {
            self.logger.info("No member, removing sub info");
            return
        }
        
//        self.currentStatusLabel = member.subs
        
    }
    
    func fetchProducts() {
        SubscriptionProductService.sharedInstance.getAllForSale { result in
            if let error = result.error {
                self.logger.error("Failed to ofetch subscription products", error)
                return
            }
            self.subscriptionProducts = result.results ?? []
            let appleIds: [String] = self.subscriptionProducts.compactMap { (p) -> String? in
                p.appleProductId
            }
            self.logger.info("[not fetching] Apple IDs to fetch.. \(appleIds)")
//            self.fetchAppleProducts(matchingIdentifiers: appleIds)
        }
    }
    
    /* not using in this release
    fileprivate func fetchAppleProducts(matchingIdentifiers identifiers: [String]) {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)

        // Initialize the product request with the above identifiers.
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self

        // Send the request to the App Store.
        productRequest?.start()
    }
    */
    
    func updateProductButtons() {
        DispatchQueue.main.async {
            if self.productEntries.isEmpty {
                self.allOptionsButton.isHidden = true
                self.cactusPlusButton.isHidden = true
            } else {
                self.allOptionsButton.isHidden = false
                self.cactusPlusButton.isHidden = false
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowUpgradeOptions", let vc = segue.destination as? SubscriptionProductCollectionViewController {
            vc.dataSource = self.productEntries
        } else if segue.identifier == "ShowSubProductDetail", let vc = segue.destination as? SubscriptionProductDetailViewController {
            vc.product = self.productEntries[0]            
        }
    }
    
}

/*
extension ManageSubscriptionViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.logger.info("Product request did return")
        
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            self.logger.info("Found \(response.products.count): \(response.products)")
            availableProducts = response.products
//            storeResponse.append(Section(type: .availableProducts, elements: availableProducts))
            self.updateProductButtons()
        }

        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            self.logger.warn("Fouond invalid products: \(response.invalidProductIdentifiers)")
//            invalidProductIdentifiers = response.invalidProductIdentifiers
//            storeResponse.append(Section(type: .invalidProductIdentifiers, elements: invalidProductIdentifiers))
        }
    }
}
*/
