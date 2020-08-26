//
//  ComposeNoteButton.swift
//  Cactus
//
//  Created by Neil Poulin on 8/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import NoveFeatherIcons

struct ComposeNoteButton: View {
    @EnvironmentObject var session: SessionStore
    let generator = UINotificationFeedbackGenerator()
    enum ActiveSheet: Identifiable {
        case compose
        
        var id: Int {
            self.hashValue
        }
    }
    
    @State var activeSheet: ActiveSheet?
    
    func getSheetView(_ item: ActiveSheet) -> AnyView {
        switch item {
        case .compose:
            guard let member = self.session.member else {
                return NoContentErrorView().eraseToAnyView()
            }
            let prompt = ReflectionPrompt.createFreeform(member: member)
            let response = ReflectionResponse.createFreeform(member: member)
            return EditNoteView(response: response, prompt: prompt, onDone: {
                self.activeSheet = nil
            }, onCancel: {
                self.activeSheet = nil
            }).eraseToAnyView()
        }
    }
    
    func simpleSuccess() {
        generator.notificationOccurred(.success)
    }
    
    var body: some View {
        Icon.getImage(Feather.IconName.edit2)?.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            .padding()
            .background(named: .Green)
            .foregroundColor(NamedColor.TextWhite.color)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
            .onTapGesture{
                self.simpleSuccess()
                self.activeSheet = .compose
            }
            .sheet(item: self.$activeSheet) { item in
                self.getSheetView(item).environmentObject(self.session)
            }
    }
}

struct ComposeNoteButton_Previews: PreviewProvider {
    static var previews: some View {
        ComposeNoteButton()
    }
}
