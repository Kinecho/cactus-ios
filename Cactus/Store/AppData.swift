//
//  AppData.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class AppData: ObservableObject {        
    @Published var authLoaded = false
    @Published var member: CactusMember?
}

extension AppData {
    static func mockLoggedIn() -> AppData {
        let data = AppData()
        let member = CactusMember()
        
        member.email = "test@cactus.app"
        member.id = "test_123"
        
        data.authLoaded = true
        data.member = member
        
        return data
    }
}
