//
//  CactusConfig.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct CactusConfig: AppConfig {
    static let appType = AppType.IOS
//    static let webDomain = "https://cactus-app-stage.web.app"
    static let webDomain = "http://192.168.1.6:8080"
//    static let webDomain = "https://cactus-web.ngrok.io"
    static let flamelink = FlamelinkConfig()
    static let environment = AppEnvironment.stage
    static let actionCodeDomain = "https://cactus-app-stage.web.app"
//    static var apiDomain = "https://us-central1-cactus-app-stage.cloudfunctions.net"
    static var apiDomain = "https://cactus-api.ngrok.io/cactus-app-stage/us-central1"
    static let customScheme = "app.cactus-stage"
    static let branchPublicKey = "key_test_hnUHuOjICDVjjN3W0PIRxlnfsyeXRjbe"
    static let appGroupId = "com.cactus.StageApp.group1"
    static let sharedKeychainGroup = "3ZKVS4B79Q.com.cactus.CactusStageAppShared"
    static let revenueCatPublicApiKey = "GJqLQgWbsSOINNAjEApbhYVWHDzmYfXA"
    
}
