//
//  URLExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 11/15/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

extension URL {
    func getQueryParams() -> [String: String] {
        var parameters: [String: String] = [:]
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        return parameters
    }
    
    func getPathId(for name: String) -> String? {
        let parts = self.pathComponents
        guard let nameIndex = parts.firstIndex(of: name), parts.endIndex > nameIndex + 1 else {
            return nil
        }
        
        return  parts[nameIndex + 1]
    }
}
