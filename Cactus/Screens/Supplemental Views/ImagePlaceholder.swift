//
//  SwiftUIView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct CardShimmer: View {
    @State var show = false
    
    var cornerRadius: CGFloat = 10
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.09)
                    .frame(height: geometry.size.height)
                    .cornerRadius(self.cornerRadius)
                
                Color.white.opacity(0.1)
                    .frame(height: geometry.size.height)
                    .cornerRadius(self.cornerRadius)
                .mask(
                    Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.clear, Color.white.opacity(0.1), .clear]), startPoint: .top, endPoint: .bottom)
                    )
                        .scaleEffect(x: 2, y: 2, anchor: .center)
                        .rotationEffect(.init(degrees: 70))
                        .offset(x: self.show ? geometry.size.width * 2 : -2 * geometry.size.width)
                
                )
            }
            .onAppear {
                withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)) {
                    self.show.toggle()
                }
            }
        }
    }
}

struct ImagePlaceholder: View {
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat = 10
    
    @EnvironmentObject var session: SessionStore
    var useMockImages: Bool {
        session.useMockImages
    }
    
    var body: some View {
        Group {
            if self.useMockImages {
                Image(CactusImage.blob0.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.width, height: self.height)                
            } else {
                Color(CactusColor.skeletonBase).frame(width: self.width, height: self.height)
                    .cornerRadius(self.cornerRadius)
            }
        }
        
        

// Shimmer is crashing at runtime with error Could not cast value of type 'CALayer' (0x7fff87e637c8) to 'SwiftUI.MaskLayer' (0x7fff87efafe0).
//        CardShimmer(cornerRadius: self.cornerRadius)
//            .frame(width: self.height, height: self.width)
    }
}

struct ImagePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        ImagePlaceholder(width: 200, height: 200, cornerRadius: 10).environmentObject(SessionStore.mockLoggedIn())
    }
}
