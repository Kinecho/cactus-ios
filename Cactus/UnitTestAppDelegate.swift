//
//  UnitTestAppDelegate.swift
//  Cactus UnitTests
//
//  Created by Neil Poulin on 5/22/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class UnitTestAppDelegate: UIResponder, UIApplicationDelegate {
    let logger = Logger("UnitTestAppDelegate")
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let rootVc = ScreenID.AppMain.getViewController() as? AppMainViewController else {
            fatalError("Unable to start main view controller in App Delegate")
        }
        NavigationService.initialize(rootVc: rootVc, delegate: self)
        
        self.window?.rootViewController = rootVc
        self.window?.makeKeyAndVisible()
                
        return true
    }
}

extension UnitTestAppDelegate: NavigationServiceDelegate {
    func open(url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?) {
        logger.info("Open URL called for URL \(url.absoluteString)")
    }
}
