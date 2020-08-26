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
    var color: Color = NamedColor.TextDefault.color
//    fileprivate var configuration = { (indicator: UIView) in }

    
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.color = self.color.toUIColor()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        uiView.color = self.color.toUIColor()
    }
}


struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                        .foregroundColor(NamedColor.TextDefault.color)
                        .font(CactusFont.normal.font)
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }

                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }
}


struct Loading: View {
    var text: String?
    
    init(_ text: String?="Loading") {
        self.text = text
    }
    
    var body: some View {
            VStack(alignment: .center) {
                Spacer()
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                if self.text != nil {
                    Text(self.text!)
                }
                Spacer()
            }
            .frame(width: 200,
                   height: 150 )
            .background(Color.secondary.colorInvert())
            .foregroundColor(NamedColor.TextDefault.color)
            .font(CactusFont.normal.font)
            .cornerRadius(CornerRadius.normal)
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
