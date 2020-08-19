//
//  CoreValuesWidget.swift
//  Cactus
//
//  Created by Neil Poulin on 8/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons
struct CoreValuesWidget: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(uiImage: Icon.getImage(Feather.IconName.lock)!)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(named: .White)
                    .offset(x: 0, y: 4)
                
                VStack(alignment: .leading) {
                    Text("What are your core values?")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(NamedColor.White.color)
                        .font(CactusFont.bold(.title).font)
                    Text("Discover what drives your life decisions and deepest needs")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(NamedColor.White.color)
                }
            }
        }
        .maxWidth(.infinity)
        .padding(Spacing.normal)
            .background(NamedColor.Dolphin.color)
        .cornerRadius(CornerRadius.normal)
        /// End Core Values
    }
}

struct CoreValuesWidget_Previews: PreviewProvider {
    static var previews: some View {
        CoreValuesWidget()
    }
}
