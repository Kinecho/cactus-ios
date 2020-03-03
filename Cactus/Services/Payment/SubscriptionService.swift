//
//  CheckoutService.swift
//  Cactus
//
//  Created by Neil Poulin on 2/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

//Methods to help with the checkout process
class SubscriptionService: NSObject {
    static var sharedInstance = SubscriptionService()
    var logger = Logger("CheckoutService")
    var subscriptionProductService = SubscriptionProductService.sharedInstance
    
    var appleProductRequest: SKProductsRequest?
    var availableAppleProducts: [SKProduct] = []
    var invalidAppleProductIds: [String]?
        
    var upgradeTrialDescription = "After your trial of Cactus Plus, you'll continue to get free prompts, but only occasionally."
        + " Give your reflection practice momentum by receiving a fresh prompt, every day"
    
    var upgradeBasicDescription = "Give your reflection practice momentum by receiving a fresh prompt, every day"
    
    func getSubscriptionProductGroupEntryMap(_ onData: @escaping (SubscriptionProductGroupEntryMap?) -> Void) {
        SubscriptionProductGroupService.sharedInstance.getAll { (groupResult) in
            if let error = groupResult.error {
                self.logger.error("Failed to get product groups from flamelink", error)
                onData(nil)
                return
            }
            let productGroups = groupResult.results
            
            SubscriptionProductService.sharedInstance.getAllForSale { (productResult) in
                if let productError = productResult.error {
                    self.logger.error("Failed to get product from flamelink", productError)
                    onData(nil)
                    return
                }
                let products = productResult.results
                
                let map = createSubscriptionProductGroupEntryMap(products: products, groups: productGroups)
                onData(map)
                return
            }
        }
        
        return
    }
    
    func learnMoreAboutUpgradeTapped(target: UIViewController) {
        AppSettingsService.sharedInstance.getSettings { (settings, _) in
            let useWeb = settings?.checkoutSettings?.useWebForCheckout ?? false
            let learnMorePath = settings?.checkoutSettings?.learnMorePath
            let url: URL? = learnMorePath != nil ? URL(string: "\(CactusConfig.webDomain)\(learnMorePath!)") : nil
                    
            if useWeb, url != nil {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.Pricing)
                target.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func fetchAppleProducts(appleProductIds identifiers: [String]) {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)

        // Initialize the product request with the above identifiers.
        self.appleProductRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        self.appleProductRequest?.delegate = self

        // Send the request to the App Store.
        self.appleProductRequest?.start()
    }
    
    func getSubscriptionDetails(_ onData: @escaping (SubscriptionDetails?, Any?) -> Void) {
        ApiService.sharedInstance.get(path: .checkoutSubscriptionDetails, responseType: SubscriptionDetails.self, authenticated: true) { response, error in
            onData(response, error)
        }
    }
}

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.logger.info("Product request did return")
        
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            self.logger.info("Found \(response.products.count): \(response.products)")
            availableAppleProducts = response.products
//            storeResponse.append(Section(type: .availableProducts, elements: availableProducts))
//            self.updateProductButtons()
        }

        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            self.logger.warn("Fouond invalid products: \(response.invalidProductIdentifiers)")
            self.invalidAppleProductIds = response.invalidProductIdentifiers
//            storeResponse.append(Section(type: .invalidProductIdentifiers, elements: invalidProductIdentifiers))
        }
    }
}
