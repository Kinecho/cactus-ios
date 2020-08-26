//
//  MoreActionsButton.swift
//  Cactus
//
//  Created by Neil Poulin on 8/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct MoreActionsButton: View {
    @Binding var showMoreActions: Bool
    
    var color: Color
    
    init(active: Binding<Bool>, color: Color=NamedColor.TextDefault.color) {
        self._showMoreActions = active
        self.color = color
    }
    
    let dotsRotationAnimation = Animation.interpolatingSpring(mass: 0.2, stiffness: 25, damping: 2.5, initialVelocity: -0.5)
    
    var body: some View {
        Image(CactusImage.dots.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundColor(self.color)
            .frame(width: 24, height: 16)
            .rotationEffect(.degrees(self.showMoreActions ? 90 : 0))
            .onTapGesture {
                withAnimation(self.dotsRotationAnimation) {
                    self.showMoreActions.toggle()
                }
        }
    }
}



struct MoreActionsButton_Previews: PreviewProvider {

    private struct StatefulPreviewWrapper: View {
        @State var active = false
        
        init (initial: Bool) {
            self.active = initial
        }
        
        var body: some View {
            MoreActionsButton(active: self.$active)
        }
    }
    
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { color in
                Group {
                    StatefulPreviewWrapper(initial: true)
                        .previewDisplayName("Active (\(String(describing: color)))")
                        
                    
                    StatefulPreviewWrapper(initial: false)
                        .previewDisplayName("Inactive (\(String(describing: color)))")
                    
                }
                .padding()
                .backgroundFill(NamedColor.Background.color)
                .colorScheme(color)
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
