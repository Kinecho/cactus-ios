//
//  WordBubbleWidget.swift
//  Cactus
//
//  Created by Neil Poulin on 8/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct WordBubbleWidget: View {
    @EnvironmentObject var session: SessionStore
    
    var words: [InsightWord]? {
        self.session.member?.wordCloud
    }
    
    
    var body: some View {
        VStack {
            if self.words?.isEmpty == false {
                WordBubblesChartView(words: self.words)
            } else {
                EmptyView()
            }
            
        }
        .padding()        
    }
}

struct WordBubbleWidget_Previews: PreviewProvider {
    static var previews: some View {
        WordBubbleWidget()
    }
}
