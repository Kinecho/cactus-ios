//
//  AppConfig.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct FlamelinkConfig {
    var environmentId:String = "production"
}

protocol AppConfig {
    static var webDomain: String {get}
    static var flamelink: FlamelinkConfig{get}
}
