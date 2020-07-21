//
//  MarkdownText.swift
//  Cactus
//
//  Created by Neil Poulin on 7/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct AttributedLabel: UIViewRepresentable {
    let markdown: String?
    let width: CGFloat?
    init(_ markdown: String?, width: CGFloat?) {
        self.markdown = markdown
        self.width = width
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        label.attributedText =  MarkdownUtil.toMarkdown(markdown)
        label.isHidden = isBlank(self.markdown)
//        label.sizeThatFits(CGSize(width: 300, height: 200))
        if let width = self.width {
            label.preferredMaxLayoutWidth = width
        }
//        label.preferredMaxLayoutWidth = context.environment.geo
        
        label.numberOfLines = 0
        label.autoresizesSubviews = true
        label.translatesAutoresizingMaskIntoConstraints = true
        label.lineBreakMode = .byWordWrapping
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        label.sizeToFit()
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText =  MarkdownUtil.toMarkdown(markdown)
        uiView.isHidden = isBlank(self.markdown)
    }
}

struct MarkdownText: View {
    var markdown: String?
    
    init(_ text: String?=nil) {
        self.markdown = text
    }
    
    var body: some View {
        GeometryReader { geometry in
            AttributedLabel(self.markdown, width: geometry.size.width).padding(EdgeInsets())
        }
    }

}

struct MarkdownText_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MarkdownText("this is **a really great** question! that goes on and on and on for ever until we can't fit on one line anymore.")
                .multilineTextAlignment(.leading)
        }.padding(100)
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
