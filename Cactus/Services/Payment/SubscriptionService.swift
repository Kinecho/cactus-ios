//
//  CheckoutService.swift
//  Cactus
//
//  Created by Neil Poulin on 2/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//


import Foundation
import UIKit

//Methods to help with the checkout process
class SubscriptionService {
    static var sharedInstance = SubscriptionService()
    var logger = Logger("CheckoutService")
    var subscriptionProductService = SubscriptionProductService.sharedInstance
    
    private init(){
        //Nothing to configure
    }
    
    func getSubscriptionProductGroupEntryMap(_ onData: @escaping (SubscriptionProductGroupEntryMap?) -> Void) -> Void {
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
}
