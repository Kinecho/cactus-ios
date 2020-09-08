//
//  ElementAnimationRepresentable.swift
//  Cactus
//
//  Created by Neil Poulin on 9/3/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct ElementAnimationRepresentable: UIViewRepresentable {
    var element: CactusElement
    var running: Bool = true
    
    func makeUIView(context: Context) -> CactusElementWebView {
        let view = CactusElementWebView()
        view.running = self.running
        view.element = self.element
        view.updateView()
        view.startAnimation()
        view.backgroundColor = .blue
        return view
    }
    
    func updateUIView(_ uiView: CactusElementWebView, context: Context) {
        uiView.element = self.element
        uiView.running = self.running        
    }
    
    typealias UIViewType = CactusElementWebView
}

struct ElementAnimationRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ElementAnimationRepresentable(element: .emotions,
                                          running: true)
                .frame(width: 300, height: 300)
                .padding()
                .background(named: .Yellow)
        }
            .previewLayout(.sizeThatFits)
        .padding()
        .background(named: .Indigo)
            
    }
}
