//
//  ReflectCardView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/2/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct ReflectCardView: View {
    var model: ReflectCardViewModel
    
    @State var animationRunning: Bool = true
    
    var body: some View {
        VStack {
            Text("REFLECT CARD")
            Text(model.promptContent.getDisplayableQuestion() ?? "no question found")
            if self.model.promptContent.cactusElement != nil {
                Text("Element = \(self.model.promptContent.cactusElement!.rawValue)").foregroundColor(named: .GreenDarker)
                ElementAnimationRepresentable(element: self.model.promptContent.cactusElement!, running: self.animationRunning)
            } else {
                Text("No element found")
            }
            
        }
    }
}

struct ReflectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectCardView(model: ReflectCardViewModel(promptContent: MockData.getAnsweredEntry().promptContent!, content: MockData.content("This is some plain text")))
    }
}
