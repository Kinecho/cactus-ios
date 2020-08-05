//
//  LinkedAccountsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct LinkedAccountItem: View {
    
    var provider: String
    
    var image: Image? {
        return CactusImage.fromProviderId(self.provider)?.image
    }
    
    var displayName: String {
        getProviderDisplayName(self.provider) ?? ""
    }
    
    var imageSize: CGFloat = 30
    
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.normal) {
            if self.image != nil {
                self.image!
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .aspectRatio(contentMode: .fill)
                    .ifMatches(provider == "twitter.com") { content in
                        content.foregroundColor(CactusColor.twitter.color)
                    }
            } else {
                ImagePlaceholder(width: imageSize, height: imageSize)
            }
            VStack {
                Text(self.displayName)
            }
        }
        .padding()
    }
}

struct LinkedAccountsView: View {
    var providers: [String] = []
    
    var body: some View {
        List {
            ForEach(providers, id: \.hashValue) { provider in
                LinkedAccountItem(provider: provider)
            }
        }
    }
}

struct LinkedAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LinkedAccountsView(providers: ["google.com", "facebook.com", "password", "apple.com", "twitter.com"])
                .colorScheme(.light)
                .previewDisplayName("Light Mode")
            
            LinkedAccountsView(providers: ["google.com", "facebook.com", "password", "apple.com", "twitter.com"])
                .colorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        
    }
}
