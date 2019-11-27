//
//  AppConfig.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/28/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

enum AppEnvironment: String, Codable {
    case prod
    case stage
}

struct FlamelinkConfig {
    var environmentId: String = "production"
}

/**
 Get the name of the release for reporting purposes, in the format of [BundleID].[Version].[Build]
 Example: com.cactus.CactusApp-1.0.88
 - Returns: The release name.  If the bundle id can not be found, this returns nil
 */
func getBuildVersion() -> String? {
    let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    return buildVersion
}

func getReleaseName() -> String? {
    guard let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        let bundleId = Bundle.main.bundleIdentifier else {
            return nil
    }
    
    return "\(bundleId)-\(appVersion).\(buildVersion)"
}

protocol AppConfig {
    static var webDomain: String {get}
    static var flamelink: FlamelinkConfig {get}
    static var environment: AppEnvironment {get}
    static var actionCodeDomain: String {get}
    static var apiDomain: String {get}
}
