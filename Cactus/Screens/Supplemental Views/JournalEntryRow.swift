//
//  JournalEntryRow.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import URLImage

struct JournalEntryRow: View {
    var entry: JournalEntry
    @EnvironmentObject var session: SessionStore
    @State var showPrompt = false
    @State var showMoreActions = false
    
    var imageWidth: CGFloat = 58
    
    var questionText: String? {
        return self.entry.promptContent?.getDisplayableQuestion() ?? self.entry.prompt?.question
    }
    
    var imageUrl: URL? {
        let photo = self.entry.promptContent?.getMainImageFile()
        return ImageService.shared.getUrlFromFile(photo)
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

                if self.imageUrl != nil {
                    URLImage(self.imageUrl!,
                             delay: 0.1,
                             processors: [ Resize(size: CGSize(width: self.imageWidth, height: self.imageWidth), scale: UIScreen.main.scale) ],

                    placeholder: {  _ in
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            .frame(width: self.imageWidth, height: self.imageWidth)
                            .background(Color(CactusColor.lightGray))
                            .cornerRadius(12)
                    },
                    content: {
                        $0.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: 10.0)
                    })
                        .frame(width: self.imageWidth, height: self.imageWidth)
                    
                }
                
            }
    
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
        text.backgroundImage = ContentBackgroundImage(storageUrl: "https://firebasestorage.googleapis.com/v0/b/cactus-app-prod.appspot.com/o/flamelink%2Fmedia%2F200707.png?alt=media&token=3ff817ca-f58f-457a-aff0-bbefebb095ad")
        
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
            JournalEntryRow(entry: self.getLoadingEntry()).previewDisplayName("Loading")
            JournalEntryRow(entry: self.getNoTextEntry()).previewDisplayName("No Question")
            JournalEntryRow(entry: self.getEntry()).previewDisplayName("Question & Image")
        }
        .padding()
        .background(Color.gray)
        .previewLayout(.fixed(width: 400, height: 300))
        //        .previewLayout(.fixed(width: 400, height: 600))
        
    }
}
