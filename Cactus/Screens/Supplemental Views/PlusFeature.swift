//
//  PlusFeature.swift
//  Cactus
//
//  Created by Neil Poulin on 8/3/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PlusFeature: View {
    
    var icon: String
    var title: String
    var description: String?
    
    var iconImage: Image? {
        return Icon.getImage(self.icon)?.image
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: Spacing.normal) {
                if self.iconImage != nil {
                    self.iconImage!.resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(CactusColor.magenta.color)
                }
                VStack(alignment: .center, spacing: -5) {
                    MDText(markdown: self.title, alignment: .center)
                        .font(CactusFont.bold(FontSize.normal).font)
                        .multilineTextAlignment(.center)
                        .foregroundColor(CactusColor.textDefault.color)
                    if self.description != nil {
                        MDText(markdown: self.description!, alignment: .center)
                            .font(CactusFont.normal(FontSize.normal).font)
                            .multilineTextAlignment(.center)
                            .foregroundColor(CactusColor.textDefault.color)
                    }
                }
            }
            Spacer()
        }.padding(.vertical)
    }
}

struct PlusFeature_Previews: PreviewProvider {
    static var previews: some View {
        PlusFeature(icon: "journal", title: "Daily _Questions_ to reflet on", description: "Get daily prompts to help you keep your journaling habit")
    }
}
