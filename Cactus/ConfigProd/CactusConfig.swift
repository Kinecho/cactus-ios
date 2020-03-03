//
//  CactusConfig.swift
//  Cactus Prod
//
//  Created by Neil Poulin on 7/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct CactusConfig: AppConfig {
    static let appType = AppType.IOS
    static let webDomain = "https://cactus.app"
    static let flamelink = FlamelinkConfig()
    static let environment = AppEnvironment.prod
    static let actionCodeDomain = "https://cactus.app"
    static var apiDomain = "https://us-central1-cactus-app-prod.cloudfunctions.net"
    static let customScheme = "app.cactus"
    static let branchPublicKey = "key_live_heLJqNeQvEOgkUX3XUF92hadCFi7uWW0"
    static let appGroupId = "com.cactus.CactusApp.group1"
    static let sharedKeychainGroup = "3ZKVS4B79Q.com.cactus.CactusAppShared"
}
