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
        ScrollView(.vertical) {
            VStack {
                Text("Insights Page")
                IconImage(.home)
                    .foregroundColor(CactusColor.magenta.color)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            
        }
        
        .background(named: .Background)
        
    }
}

struct InsightsHome_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { color in
                Group {
                    InsightsHome().previewDisplayName("No Nav Wrapper (\(String(describing: color)))")
                    .background(named: .Background)
                    .colorScheme(color)
                    
                }
                Group {
                    NavigationView {
                        InsightsHome().navigationBarTitle("Home")
                    }
                        .previewDisplayName("Insights Home (\(String(describing: color)))")
                    .background(named: .Background)
                    .colorScheme(color)
                    
                }
            }
        }
        
        
    }
}
