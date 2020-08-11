//
//  JournalEntryInlineImage.swift
//  Cactus
//
//  Created by Neil Poulin on 8/11/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import URLImage

struct JournalEntryInlineImage: View {
    @EnvironmentObject var session: SessionStore
    var imageUrl: URL
    
    var imageWidth: CGFloat = 300
    var imageHeight: CGFloat = 200
    var imageOffsetX: CGFloat {
        return self.imageWidth / 3
    }
    let imageOffsetY: CGFloat = 55
    var body: some View {
       
            HStack {
                Spacer()
                URLImage(self.imageUrl,
                         placeholder: {_ in
                            Group {
                                ImagePlaceholder(width: self.imageWidth, height: self.imageHeight)
                            }
                },
                         content: {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                })
                    .frame(width: self.imageWidth, height: self.imageHeight, alignment: .top)
                    .offset(x: 0, y: self.imageOffsetY)
                    .padding(.top, -self.imageOffsetY)
                Spacer()
                
            }
        }
}

struct JournalEntryInlineImage_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryInlineImage(imageUrl: MockData.getUnansweredEntry(blob: 3).imageUrl!)
            .environmentObject(SessionStore.mockLoggedIn())
    }
}
