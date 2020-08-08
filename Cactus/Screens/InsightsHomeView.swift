//
//  InsightsHome.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons
struct InsightsHome: View {
    var body: some View {
        VStack {
            Text("Insights Page")
            IconImage(.home)
                .foregroundColor(CactusColor.magenta.color)
            
            
        }
        
    }
}

struct InsightsHome_Previews: PreviewProvider {
    static var previews: some View {
        InsightsHome()
    }
}
