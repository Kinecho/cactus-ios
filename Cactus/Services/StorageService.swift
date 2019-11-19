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
    
    func removeLocalSignupQueryParams() {
        self.userDefaults.removeObject(forKey: UserDefaultsKey.signupQueryParams)
    }
}
