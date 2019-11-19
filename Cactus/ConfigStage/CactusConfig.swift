//
//  CactusConfig.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct CactusConfig: AppConfig {
    static let webDomain = "https://cactus-app-stage.web.app"
    static let flamelink = FlamelinkConfig()
    static let environment = AppEnvironment.stage
    static let actionCodeDomain = "https://cactus-app-stage.web.app"
    static var apiDomain = "https://us-central1-cactus-app-stage.cloudfunctions.net"
//    static var apiDomain = "https://cactuslocal.ngrok.io/cactus-app-stage/us-central1"
}
