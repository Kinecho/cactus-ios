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
    
    var questionText: String? {
        return self.entry.promptContent?.getDisplayableQuestion() ?? self.entry.prompt?.question
    }
    
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
                Text(self.questionText ?? "")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: .infinity, alignment: .topLeading)
                    .multilineTextAlignment(.leading)                
                Spacer(minLength: 20)
                Image(CactusImage.avatar1.rawValue)
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .topTrailing)
            }
            Divider()
            Text("This is the bottom Text")
        }
        .onTapGesture {
            self.showPrompt = true
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
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
        text.text_md = "this is **a really great** question!"
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
    
    static func getNoTextEntry() -> JournalEntry {
          var entry = JournalEntry(promptId: "testId")
          entry.loadingComplete = true
          
          let promptContent = PromptContent()
          let text = Content()
          text.contentType = .reflect
          text.text_md = nil
          promptContent.content = [
              text
          ]
          entry.promptContent = promptContent
          
          return entry
      }
    
    static var previews: some View {
        Group {
            JournalEntryRow(entry: self.getLoadingEntry()).previewDisplayName("Journal Loading")
            JournalEntryRow(entry: self.getNoTextEntry()).previewDisplayName("Journal No Text")
            JournalEntryRow(entry: self.getEntry()).previewDisplayName("Journal Entry")
        }
        .padding()
        .background(Color.gray)
        .previewLayout(.fixed(width: 400, height: 300))
        //        .previewLayout(.fixed(width: 400, height: 600))
        
    }
}
