//
//  PreviewHelperView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PreviewHelperView<Content: View>: View {
    var devices: [MockDevice] = [MockDevice.iPhone11(), MockDevice.iPadPro12inch()]
    var colors: [ColorScheme] = [.light, .dark]
    var name: String = ""
    var content: () -> Content
    var body: some View {
        
        ForEach(devices) {device in
            ForEach(colors, id: \.self) {color in
                self.content().previewDevice(device.previewDevice)
                    .colorScheme(color)
                    .environment(\.horizontalSizeClass, device.horizontalSize)
                    .previewDisplayName("\(self.name) - \(color)")
            }
        }
    }
}

struct PreviewHelperView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewHelperView(name: "Fake Content", content: {
            Text("Some fake text")
                .background(named: .Background)
        })
    }
}
