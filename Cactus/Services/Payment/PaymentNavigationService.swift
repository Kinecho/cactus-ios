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
        let learnMorePath = settings?.checkoutSettings?.learnMorePath
        let url: URL? = learnMorePath != nil ? URL(string: "\(CactusConfig.webDomain)\(learnMorePath!)") : nil
                        
        guard let vc = ScreenID.Pricing.getViewController() as? PricingViewController else {
            return
            
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.showCloseButton = true
        
        NavigationService.sharedInstance.present(vc, animated: true)
    }

}
