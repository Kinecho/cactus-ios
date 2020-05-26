//
//  RatingReviewService.swift
//  Cactus
//
//  Created by Neil Poulin on 5/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit

class RatingReviewService {
    static var shared: RatingReviewService = RatingReviewService()
    
    private init() {}
    
    func askForReviewIfAppropriate(completed: ((Bool) -> Void)?) {
        completed?(true)
    }
}
