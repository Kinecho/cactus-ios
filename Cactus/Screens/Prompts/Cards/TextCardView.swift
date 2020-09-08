//
//  TextCardView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import URLImage
struct TextCardView: View {
    @EnvironmentObject var session: SessionStore
    var model: TextCardViewModel
    
    var usePlaceholder: Bool {
        self.session.useMockImages
    }
    
    var backgroundImageSize: CGSize = CGSize(200, 200)
    var body: some View {
        AdaptiveStack(horizontalSpacing: Spacing.large, verticalSpacing: Spacing.normal) {
            Text(self.model.textMarkdown ?? "")
            if self.model.imageUrl != nil {
                URLImage(self.model.imageUrl!,
                         placeholder: {_ in
                            Group {
                                if self.usePlaceholder {
                                    Image(CactusImage.blob0.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: self.backgroundImageSize.width,
                                               height: self.backgroundImageSize.height)
                                } else {
                                    ImagePlaceholder(width: self.backgroundImageSize.width,
                                                     height: self.backgroundImageSize.height)
                                }
                            }
                },
                         content: {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                })
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        
    }
}

struct TextCardView_Previews: PreviewProvider {
    static var mock1 = TextCardViewModel(promptContent: MockData.getAnsweredEntry().promptContent!,
                                         content: MockData.content("This is some plain text", backgroundImage: MockData.getBlobImage(2)))
    static var previews: some View {
        Group {
            PreviewHelperView(name: "Mock1", content: {
                ScrollView(.vertical) {
                    TextCardView(model: mock1)
                }
                    .background(named: .Background)
                
            })
            .environmentObject(SessionStore.mockLoggedIn())
        }
    }
}
