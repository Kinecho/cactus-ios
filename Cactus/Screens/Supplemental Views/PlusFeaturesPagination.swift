//
//  PlusFeaturesPagination.swift
//  Cactus
//
//  Created by Neil Poulin on 8/3/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import SwiftUIX

struct PlusFeaturesPagination: View {
    var features: [PricingFeature]
    var height: CGFloat
    var items: [PricingFeature] {
        return features.filter { (f) -> Bool in
            return f.titleMarkdown != nil && f.icon != nil && f.descriptionMarkdown != nil
        }
    }
    
    init(features: [PricingFeature], height: CGFloat = 200) {
        self.features = features
        self.height = height
    }
    
    var body: some View {
        VStack {
            if self.items.count > 0 {
                PaginationView(axis: .horizontal) {
                    ForEach(self.items) { feature in
                        ScrollView(.vertical) {
                            PlusFeature(icon: feature.icon!,
                                        title: feature.titleMarkdown!,
                                        description: feature.descriptionMarkdown!)
                            .padding()
                        }                    
                        .onAppear {
                            UIScrollView.appearance().bounces = false
                        }.onDisappear {
                            UIScrollView.appearance().bounces = true
                        }
                    }
                }
            }
        }
    }
}

struct PlusFeaturesPagination_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack(alignment: .top) {
                VStack {
                    PlusFeaturesPagination(features: PricingScreenSettings.defaultSettings().features)
                    .pageIndicatorTintColor(CactusColor.darkestGreen.color)
                    .currentPageIndicatorTintColor(CactusColor.green.color)
                        .environment(\.currentPageIndicatorTintColor, CactusColor.darkestGreen.color)
                    .environment(\.pageIndicatorTintColor, CactusColor.green.color)
                    Spacer()
                }
            }
            .height(350)
            .background(CactusColor.beige.color)
            .previewDisplayName("Default Features")
            
            VStack {
                PlusFeaturesPagination(features: [])
                Spacer()
            }.previewDisplayName("No Features")
        }
    }
}
