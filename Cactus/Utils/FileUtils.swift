//
//  FileUtils.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

public struct FileUtils {
    
    static func isGif(_ urlString: String? ) -> Bool {
        guard let urlString = urlString, !FormatUtils.isBlank(urlString) else {
            return false
        }
        
        let url = URL(string: urlString)
        return url?.pathExtension == "gif"
    }
}
