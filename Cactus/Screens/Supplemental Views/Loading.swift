//
//  Loading.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
struct Loading: View {
    var text: String?
    
    init(_ text: String?="Loading") {
        self.text = text
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                if self.text != nil {
                    Text(self.text!)
                }
            }
            .frame(width: geometry.size.width / 2,
                   height: geometry.size.height / 5)
            .background(Color.secondary.colorInvert())
            .foregroundColor(Color.primary)
            .cornerRadius(20)
        }
    }

}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Loading("Please Wait...").previewDisplayName("Custom Text")
            Loading().previewDisplayName("Default Text")
            Loading(nil).previewDisplayName("No Text")
        }
        
    }
}
