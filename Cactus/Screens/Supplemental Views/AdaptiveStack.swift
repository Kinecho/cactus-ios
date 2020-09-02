//
//  AdaptiveStack.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) var sizeClass: UserInterfaceSizeClass?
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if self.sizeClass == .compact {
            VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
        } else {
            HStack(alignment: verticalAlignment, spacing: spacing, content: content)
        }
    }
}

struct AdaptiveStack_Previews: PreviewProvider {
    struct Device: Identifiable {
        var id: Int
        var device: String
        var horizontalSize: UserInterfaceSizeClass = .compact
    }
    
    static let devices: [Device] = [
        Device(id: 0, device: "iPad Pro (12.9-inch)", horizontalSize: .regular),
        Device(id: 1, device: "iPhone 11", horizontalSize: .compact),
    ]
    
    static var previews: some View {
        Group {
                ForEach(self.devices) { device in
                    VStack {
                            Text("Set with Environment values")
                        AdaptiveStack(spacing: Spacing.normal) {
                                Text("Horizontal when there's lots of space")
                                Circle().frame(width: 100, height: 100).foregroundColor(.blue)
                                Text("but")
                                Rectangle().frame(width: 100, height: 100).foregroundColor(.red)
                                Text("Vertical when space is restricted")
                            }
                    }
                    .foregroundColor(named: .TextDefault)
                    .padding(Spacing.large)
                    .background(named: .Background)
                    .environment(\.horizontalSizeClass,device.horizontalSize)
                    .previewDevice(PreviewDevice.init(rawValue: device.device))
                    .previewDisplayName("\(device.device) - \(device.horizontalSize)")
                }
            }
        
    }
}
