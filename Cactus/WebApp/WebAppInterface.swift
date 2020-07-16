//
//  WebAppInterface.swift
//  Cactus
//
//  Created by Neil Poulin on 7/16/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import WebKit

enum WebkitMessageHandler: String, CaseIterable {
    case appMounted
    case closeCoreValues
    case showPricing        
}

extension WKUserContentController {
    func registerMessageHandlers(with handler: WKScriptMessageHandler) {
        WebkitMessageHandler.allCases.forEach { (messageName) in            
            self.add(handler, name: messageName.rawValue)
        }
    }
}
