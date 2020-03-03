//
//  PaymentNavigationService.swift
//  Cactus
//
//  Created by Neil Poulin on 3/3/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit

func learnMoreAboutUpgradeTapped(target: UIViewController) {
    AppSettingsService.sharedInstance.getSettings { (settings, _) in
        let useWeb = settings?.checkoutSettings?.useWebForCheckout ?? false
        let learnMorePath = settings?.checkoutSettings?.learnMorePath
        let url: URL? = learnMorePath != nil ? URL(string: "\(CactusConfig.webDomain)\(learnMorePath!)") : nil
                
        if useWeb, url != nil {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            guard let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.Pricing) as? PricingViewController else {
                return
                
            }
            vc.showCloseButton = true
            target.present(vc, animated: true, completion: nil)
        }
    }
}
