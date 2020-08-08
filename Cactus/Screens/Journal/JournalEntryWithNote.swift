//
//  JournalEntryWithNote.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalEntryWithNote: View {
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
                .fixedSize(horizontal: false, vertical: true)
            }
            
            if !isBlank(self.responseText) {
                Text(self.responseText!)
                    .multilineTextAlignment(.leading)
                    .font(Font(CactusFont.normal))
                    .foregroundColor(Color(CactusColor.textDefault))
                    .padding([.leading], 20)
                    .padding(.vertical, 4)
                    .fixedSize(horizontal: false, vertical: true)
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


struct JournalEntryWithNote_Previews: PreviewProvider {    
    struct RowData: Identifiable {
        var id: String {
            return entry.id
        }
        let entry: JournalEntry
        let name: String
    }
    
    static var rowData: [(entry: JournalEntry, name: String)] = [
        (entry: MockData.getAnsweredEntry(blob: 2), name: "Has Response"),
        (entry: MockData.getAnsweredEntryLong(blob: 2), name: "Long Response"),
        (entry: MockData.getAnsweredEntryShort(blob: 4), name: "Short Response"),
        (entry: MockData.EntryBuilder(question: nil, answer: nil, blob: 5).build(), name: "No Question"),
    ]
    
    
    static var previews: some View {
        ForEach(self.rowData, id: \.entry.id) { data in
            List {
                JournalEntryWithNote(entry: data.entry).environmentObject(SessionStore.mockLoggedIn())
            }
            .previewDisplayName(data.name)
            .previewLayout(.fixed(width: 400, height: 450))
            
        }
    }
}
