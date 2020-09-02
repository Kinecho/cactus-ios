//
//  JournalEntryNoNote.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import URLImage

struct JournalEntryNoNote: View {
    @EnvironmentObject var session: SessionStore
    
    var entry: JournalEntry
    var textColor: Color = NamedColor.TextDefault.color
    
    var imageWidth: CGFloat = 300
    var imageHeight: CGFloat = 200
    var imageOffsetX: CGFloat {
        return self.imageWidth / 3
    }
    let imageOffsetY: CGFloat = 55
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.normal) {
            VStack(alignment: .leading, spacing: 0) {
                if self.entry.questionText != nil {
                    MDText(markdown: self.entry.questionText!, alignment: .leading)
                        .font(Font(CactusFont.bold(FontSize.journalQuestionTitle)))
                        .foregroundColor(self.textColor)
                        .lineLimit(nil)
                    
                }
                if self.entry.introText != nil {
                    MDText(markdown: self.entry.introText!)
                        .font(Font(CactusFont.normal))
                        .foregroundColor(self.textColor)
                        .lineLimit(nil)
                }
                
                Spacer()
            }
//            if self.entry.imageUrl != nil {
//                JournalEntryInlineImage(imageUrl: self.entry.imageUrl!)
//            }
        }
    }
}

struct JournalEntryNoNote_Previews: PreviewProvider {
    struct RowData: Identifiable {
        var id: String {
            return entry.id
        }
        let entry: JournalEntry
        let name: String
    }
    
    static var rowData: [(entry: JournalEntry, name: String)] = [
        (entry: MockData.getLoadingEntry(blob: 1), name: "loading"),
        (entry: MockData.getUnansweredEntry(blob: 3), name: "Question & Image"),
        (entry: MockData.getUnansweredEntry(isToday: true, blob: 4), name: "Today"),
        (entry: MockData.EntryBuilder(question: nil, answer: nil, blob: 5).build(), name: "No Question"),
    ]
    
    static var previews: some View {
        ForEach(self.rowData, id: \.entry.id) { data in
            Group {
                List {
                    JournalEntryNoNote(entry: data.entry).environmentObject(SessionStore.mockLoggedIn())
                        .previewDisplayName(data.name)
                        .previewLayout(.fixed(width: 400, height: 450))
                }
            }
        }
    }
}
