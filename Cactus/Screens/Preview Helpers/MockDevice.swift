//
//  MockDevice.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import SwiftUI

struct MockDevice: Identifiable {
    var id: UUID = UUID()
    var device: String
    var horizontalSize: UserInterfaceSizeClass = .compact
    
    var previewDevice: PreviewDevice {
        PreviewDevice(rawValue: self.device)
    }
    
    static func iPhone11() -> MockDevice {
        return MockDevice(device: "iPhone 11", horizontalSize: .compact)
    }
    
    static func iPadPro12inch() -> MockDevice {
        return MockDevice(device: "iPad Pro (12.9-inch)", horizontalSize: .regular)
    }
}
