//
//  JournalEntryRow.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalEntryRow: View {
    var entry: JournalEntry
    @EnvironmentObject var session: SessionStore
    @State var showPrompt = false
    
    @State var showMoreActions = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Text("Today")
                Spacer()
                Button(action: {
                    
                        self.showMoreActions.toggle()
                    
                }) {
                    Image(CactusImage.dots.rawValue)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(showMoreActions ? 90 : 0))
                        .animation(.interpolatingSpring(mass: 0.2, stiffness: 25, damping: 2, initialVelocity: -0.5))
                        .accentColor(Color(CactusColor.textMinimized))
                    
                }
            }
            Text("Journal \(entry.id) | loaded: \(entry.loadingComplete ? "Yes" : "No")")
        }
        .onTapGesture {
            self.showPrompt = true
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .clipped()
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
        .sheet(isPresented: $showPrompt) {
            PromptContentView(entry: self.entry).environmentObject(self.session)
        }
        .actionSheet(isPresented: $showMoreActions) {
            ActionSheet(title: Text("What do you want to do?"),
                        message: Text("There's only one choice..."),
                        buttons: [
                            .default(Text("Dismiss Action Sheet"))
            ])
        }
    }
}

struct JournalEntryRow_Previews: PreviewProvider {
    static func getLoadingEntry() -> JournalEntry {
        var entry = JournalEntry(promptId: "testId")
        entry.loadingComplete = false
        return entry
    }
    
    static var previews: some View {
        Group {
            JournalEntryRow(entry: self.getLoadingEntry())
            .previewDisplayName("Entry Loading")
        }.padding(40)
            .previewLayout(.fixed(width: 400, height: 300))
        
    }
}
