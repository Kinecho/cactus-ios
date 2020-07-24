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
    
    var responseText: String? {
        return entry.responseText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if self.entry.questionText != nil {
                MDText(markdown: self.entry.questionText!)
                    .font(Font(CactusFont.bold(FontSize.journalQuestionTitle)))
                    .foregroundColor(Color(CactusColor.textDefault))
                    .lineLimit(nil)
            }
            
            if !isBlank(self.responseText) {
                Text(self.responseText!)
                    .multilineTextAlignment(.leading)
                    .font(Font(CactusFont.normal))
                    .foregroundColor(Color(CactusColor.textDefault))
                    .padding([.leading, .vertical], 20)
                    .border(width: 5,
                            edge: .leading,
                            color: Color(CactusColor.highlight),
                            alignment: .leading,
                            radius: 10,
                            corners: [.topRight, .bottomRight])
                    .offset(x: -20, y: 0)
            }
        }
    }
}

struct JournalEntryNoNote: View {
    var entry: JournalEntry
    var imageWidth: CGFloat = 300
    var imageHeight: CGFloat = 200
    var imageOffsetX: CGFloat {
        return self.imageWidth / 3
    }
    
    var textWidthFactor: CGFloat {
        self.entry.imageUrl != nil ? 2 / 3 : 1
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if self.entry.questionText != nil {
                MDText(markdown: self.entry.questionText!)
                    .font(Font(CactusFont.bold(FontSize.journalQuestionTitle)))
                    .foregroundColor(Color(CactusColor.textDefault))
                    .lineLimit(nil)
                
            }
            if self.entry.introText != nil {
                MDText(markdown: self.entry.introText!)
                    .font(Font(CactusFont.normal))
                    .foregroundColor(Color(CactusColor.textDefault))
                    .lineLimit(nil)
            }
            
            if self.entry.imageUrl != nil {
                HStack {
                    Spacer()
                    URLImage(self.entry.imageUrl!,
                             processors: [
                                Resize(size: CGSize(width: self.imageWidth, height: self.imageHeight),
                                       scale: UIScreen.main.scale)],
                             placeholder: {_ in
                                EmptyView() },
                             content: {
                                $0.image
                                    .resizable()
                                    .frame(width: self.imageWidth, height: self.imageHeight)
                                    .aspectRatio(contentMode: .fit)
                    })
                        .frame(width: self.imageWidth, height: self.imageHeight)
                        .offset(x: 0, y: 55)
                        .padding(.top, -55)
                    Spacer()
                    
                }
            }
        }
    }
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
                        .font(Font(CactusFont.normal(FontSize.journalDate)))
                        .foregroundColor(Color(CactusColor.textDefault))
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
                    JournalEntryAnswered(entry: self.entry)
                } else {
                    JournalEntryNoNote(entry: self.entry)
                }
            }
        }
//        .onTapGesture {
//            self.showPrompt = true
//        }
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
    
    struct RowData: Identifiable {
        var id: String {
            return entry.id
        }
        let entry: JournalEntry
        let name: String
    }
    
    static var rowData: [(entry: JournalEntry, name: String)] = [
        (entry: MockData.getLoadingEntry(), name: "loading"),
        (entry: MockData.getAnsweredEntry(), name: "Has Response"),
        (entry: MockData.getUnansweredEntry(), name: "Question & Image"),
        (entry: MockData.getUnansweredEntry(isToday: true), name: "Today"),
        (entry: MockData.EntryBuilder(question: nil, answer: nil).build(), name: "No Question"),
    ]
    
    static var previews: some View {
        
        ForEach(self.rowData, id: \.entry.id) { data in
            List {
                JournalEntryRow(entry: data.entry)
                    .listRowInsets(EdgeInsets())
                    .padding()
            }
            .onAppear(perform: {
                UITableView.appearance().separatorStyle = .none
            })
            .previewDisplayName(data.name)
        }
    }
}
