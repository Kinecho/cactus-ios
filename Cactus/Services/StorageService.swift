//
//  StorageService.swift
//  Cactus
//
//  Created by Neil Poulin on 11/15/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

struct UserDefaultsKey {
    static let signupQueryParams = "signupQueryParams"
    static let magicLinkEmail = "MagicLinkEmail"
    static let notificationOnboarding = "NotificationOnboarding"
}

class StorageService {
    static let sharedInstance = StorageService()
    let userDefaults: UserDefaults
    let logger = Logger("StorageService")
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getLocalSignupQueryParams() -> [String: String]? {
        let queryParams = self.userDefaults.dictionary(forKey: UserDefaultsKey.signupQueryParams) as? [String: String]
        logger.debug("Got signup query params \(String(describing: queryParams))")
        return queryParams
    }
    
    func setLocalSignupQueryParams(_ params: [String: String]?) {
        guard let params = params else {return}
        
        let existingParams = self.getLocalSignupQueryParams() ?? [:]
        let updatedParams = existingParams.merging(params) { (old, _) -> String in old}
                
        self.userDefaults.set(updatedParams, forKey: UserDefaultsKey.signupQueryParams)
    }
    
    func setBranchParameters(_ params: [AnyHashable: Any]?) {
        guard let params = params else {
            return
        }
        
        self.logger.info("Setting branch params to storage service")

        var signupParams: [String: String] = [:]
        
        if let ref = params["ref"] as? String {
            signupParams["ref"] = ref
        }
        
        if let channel = params["~channel"] as? String {
            signupParams["utm_channel"] = channel
        }
        
        if let medium = params["~feature"] as? String {
            signupParams["utm_medium"] = medium
        }
        
        if let source = params["~source"] as? String {
            signupParams["utm_source"] = source
        }
        
        self.setLocalSignupQueryParams(signupParams)
    }
    
    func removeLocalSignupQueryParams() {
        self.userDefaults.removeObject(forKey: UserDefaultsKey.signupQueryParams)
    }
}
