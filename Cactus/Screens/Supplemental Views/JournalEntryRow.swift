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
        
        VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Today")
                    Spacer()
                    Button(action: {
                        
                        self.showMoreActions.toggle()
                        
                    }) {
                        Image(CactusImage.dots.rawValue)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(self.showMoreActions ? 90 : 0))
                            .animation(.interpolatingSpring(mass: 0.2, stiffness: 25, damping: 2, initialVelocity: -0.5))
                            .accentColor(Color(CactusColor.textMinimized))
                        
                    }
                }
                
                HStack(alignment: .top) {
//                        MarkdownText(self.entry.promptContent?.getQuestionMarkdown())
                    Text(self.entry.promptContent?.getQuestionMarkdown() ?? "")
//                    Image(systemName: "star")
                }
            
                Spacer()
                
                Text("Journal \(self.entry.id) | loaded: \(self.entry.loadingComplete ? "Yes" : "No")")
            }
            .onTapGesture {
                self.showPrompt = true
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(10)
            .clipped()
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
            .sheet(isPresented: self.$showPrompt) {
                PromptContentView(entry: self.entry).environmentObject(self.session)
            }
            .actionSheet(isPresented: self.$showMoreActions) {
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
        
        let promptContent = PromptContent()
        let text = Content()
        text.contentType = .reflect
        text.text_md = "this is **a really great** question! that goes on and on and on for ever until we can't fit on one line anymore."
        promptContent.content = [
            text
        ]
        entry.promptContent = promptContent
        
        return entry
    }
    
    static func getEntry() -> JournalEntry {
        var entry = JournalEntry(promptId: "testId")
        entry.loadingComplete = true
        
        let promptContent = PromptContent()
        let text = Content()
        text.contentType = .reflect
        text.text_md = "this is **a really great** question! that goes on and on and on for ever until we can't fit on one line anymore."
        promptContent.content = [
            text
        ]
        entry.promptContent = promptContent
        
        return entry
    }
    
    static var previews: some View {
        Group {
            JournalEntryRow(entry: self.getLoadingEntry()).previewDisplayName("Journal Loading")
            JournalEntryRow(entry: self.getEntry()).previewDisplayName("Journal Entry")
        }
        .padding()
        .previewLayout(.fixed(width: 400, height: 300))
//        .previewLayout(.fixed(width: 400, height: 600))
        
    }
}
