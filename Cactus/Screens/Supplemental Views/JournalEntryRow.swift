//
//  JournalEntryRow.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import URLImage

struct JournalEntryAnswered: View {
    var entry: JournalEntry
    
    var body: some View {
        Text("Hello! Answered")
    }
}

struct JournalEntryUnAnswered: View {
    var entry: JournalEntry
    var imageWidth: CGFloat = 140
    var imageOffsetX: CGFloat {
        return self.imageWidth / 3
    }
    
    var textWidthFactor: CGFloat {
        self.entry.imageUrl != nil ? 2 / 3 : 1
    }
    
    var body: some View {
        HStack(alignment: .top) {
//            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    if self.entry.questionText != nil {
                        MDText(markdown: self.entry.questionText!)
//                            .font(.headline)
                        .lineLimit(nil)
                        
                    }
                    if self.entry.introText != nil {
                        MDText(markdown: self.entry.introText!)
//                            .font(.subheadline)
                        .lineLimit(nil)
                        
                    }
                }
            
                Spacer(minLength: 20)
            
                if self.entry.imageUrl != nil {
                    URLImage(self.entry.imageUrl!,
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
                        .offset(x: self.imageOffsetX, y: 0)
                        .padding(.leading, -self.imageOffsetX)
                        
//                        .frame(width: self.imageWidth, height: self.imageWidth)
                }
            }

        }
        
//    }
    
}

struct JournalEntryRow: View {
    var entry: JournalEntry
    @EnvironmentObject var session: SessionStore
    @State var showPrompt = false
    @State var showMoreActions = false
    
    var hasResponse: Bool {
        return entry.responsesLoaded && !(entry.responses ?? []).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if entry.dateString != nil {
                    Text(entry.dateString!)
                }
                
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
            VStack(alignment: .leading) {
                if self.hasResponse {
                    //                JournalEntryAnswered(entry: self.entry)
                    JournalEntryUnAnswered(entry: self.entry)
                } else {
                    JournalEntryUnAnswered(entry: self.entry)
                }
            }
            
        }
        .onTapGesture {
            self.showPrompt = true
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
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
    
    static var previews: some View {
        Group {
            JournalEntryRow(entry: MockData.getLoadingEntry()).previewDisplayName("Loading")
            JournalEntryRow(entry: MockData.EntryBuilder(question: nil, answer: nil).build()).previewDisplayName("No Question")
            JournalEntryRow(entry: MockData.getUnansweredEntry()).previewDisplayName("Question & Image")
            JournalEntryRow(entry: MockData.getUnansweredEntry(isToday: true)).previewDisplayName("Today")
        }
        .padding()
        .background(Color.gray)
        .previewLayout(.fixed(width: 400, height: 300))
        //        .previewLayout(.fixed(width: 400, height: 600))
        
    }
}
