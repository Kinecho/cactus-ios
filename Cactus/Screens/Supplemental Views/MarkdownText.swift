//
//  Created by Andre Carrera on 10/9/19.
//  Copyright © 2019 Lambdo. All rights reserved.
//  https://github.com/Lambdo-Labs/MDText
//  MarkdownText.swift
//  Cactus
//
//  Created by Neil Poulin on 7/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct TextWithAttributedString: UIViewRepresentable {

    let attributedString: NSAttributedString?
    var width: CGFloat
    
    init(_ attributedString: NSAttributedString?, width: CGFloat) {
        self.attributedString = attributedString
        self.width = width
    }
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.backgroundColor = .green
        label.sizeToFit()
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        guard let attributedString = self.attributedString else {
            uiView.isHidden = true
            uiView.attributedText = nil
            return
        }
        uiView.isHidden = false
        uiView.attributedText = attributedString
    }
}

struct MarkdownText: View {
    var markdown: String?
    
    init(_ text: String?=nil) {
        self.markdown = text
    }
    
    var attributedString: NSAttributedString? {
        return MarkdownUtil.toMarkdown(self.markdown)
    }
    
    var body: some View {
        GeometryReader { geometry in
            TextWithAttributedString(self.attributedString, width: geometry.size.width)
                .background(Color.blue)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.red)
        }
        
    }

}

struct MarkdownText_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MarkdownText("this is **a really great** question! that goes on and on and on for ever until we can't fit on one line anymore.")
                .multilineTextAlignment(.leading)
        }.padding(20)
//            .previewLayout(.fixed(width: 400, height: 300))
    }
}
