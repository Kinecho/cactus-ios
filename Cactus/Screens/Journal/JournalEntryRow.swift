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
    var usePlaceholder: Bool {
        self.session.useMockImages
    }
    var index: Int = 0
    var inlineImage: Bool = false
    @EnvironmentObject var session: SessionStore
    @State var showPrompt = false
    @State var showMoreActions = false
    
    var showInlineImage: Bool {
        return self.entry.imageUrl != nil && (!self.hasResponse || self.inlineImage)
    }
    
    var backgroundImageAlignment: Alignment {
        self.index % 2 == 0  ? .bottomTrailing : .bottomLeading
    }
    
    var backgroundImageSize = CGSize(width: 230, height: 230)
    var backgroundImageOffset: CGFloat = 16
    var backgroundImageOffsetX: CGFloat {
        if self.backgroundImageAlignment == .bottomLeading {
            return -1 * self.backgroundImageOffset
        }
        return self.backgroundImageOffset
    }
    
    var hasResponse: Bool {
        return entry.responsesLoaded && !isBlank(entry.responseText)
    }
    
    let dotsRotationAnimation = Animation.interpolatingSpring(mass: 0.2, stiffness: 25, damping: 2.5, initialVelocity: -0.5)
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    if entry.dateString != nil {
                        Text(entry.dateString!)
                            .font(Font(CactusFont.normal(FontSize.journalDate)))
                            .foregroundColor(Color(CactusColor.textDefault))
                    }
                    
                    Spacer().animation(nil)
                    Image(CactusImage.dots.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color(CactusColor.textDefault))
                        .frame(width: 30, height: 20)
                        .rotationEffect(.degrees(self.showMoreActions ? 90 : 0))
                        .onTapGesture {
                            withAnimation(self.dotsRotationAnimation) {
                                self.showMoreActions.toggle()
                            }
                        }
                }
                Group {
                    if self.hasResponse {
                        JournalEntryWithNote(entry: self.entry)
                    } else {
                        JournalEntryNoNote(entry: self.entry)
                    }
                    
                    if self.showInlineImage {
                        JournalEntryInlineImage(imageUrl: self.entry.imageUrl!)
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding(Spacing.normal)
        .background(CactusColor.cardBackground.color)
        .cornerRadius(10)
        .clipped()
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
        .ifMatches(!self.showInlineImage && self.hasResponse && self.entry.imageUrl != nil, content: {
            $0.background(
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom, spacing: 0) {
                            if self.backgroundImageOffsetX > 0 {
                                Spacer()
                            }
                            URLImage(self.entry.imageUrl!,
                                     placeholder: {_ in
                                        Group {
                                            if self.usePlaceholder {
                                                Image(CactusImage.blob0.rawValue)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: self.backgroundImageSize.width, height: self.backgroundImageSize.height)
                                            } else {
                                                ImagePlaceholder(width: self.backgroundImageSize.width, height: self.backgroundImageSize.height)
                                            }
                                        }
                            },
                                     content: {
                                        $0.image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                            })
                                .frame(width: min(geometry.size.width, self.backgroundImageSize.width), height: min(geometry.size.height + self.backgroundImageOffset * 2, self.backgroundImageSize.height), alignment: self.backgroundImageAlignment)
                                .offset(x: self.backgroundImageOffsetX, y: geometry.size.height > self.backgroundImageSize.height ? self.backgroundImageOffset : 0)
                                
                            if self.backgroundImageOffsetX < 0 {
                                Spacer()
                            }
                        }
                    }
                }
            )
        })
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
        (entry: MockData.getLoadingEntry(blob: 1), name: "loading"),
        (entry: MockData.getAnsweredEntry(blob: 2), name: "Has Response"),
        (entry: MockData.getAnsweredEntryLong(blob: 2), name: "Long Response"),
        (entry: MockData.getAnsweredEntryShort(blob: 4), name: "Short Response"),
        (entry: MockData.getUnansweredEntry(blob: 3), name: "Question & Image"),
        (entry: MockData.getUnansweredEntry(isToday: true, blob: 4), name: "Today"),
        (entry: MockData.EntryBuilder(question: nil, answer: nil, blob: 5).build(), name: "No Question"),
    ]
    
    static var previews: some View {
        Group {
            ForEach(self.rowData, id: \.entry.id) { data in
                Group {
                    List {
                        JournalEntryRow(entry: data.entry)
                            .listRowInsets(EdgeInsets())
                            .padding(Spacing.large)
                            .background(CactusColor.background.color)
                    }.environmentObject(SessionStore.mockLoggedIn())
                        .onAppear(perform: {
                            UITableView.appearance().separatorStyle = .none
                            UITableView.appearance().backgroundColor = CactusColor.background
                        })
                        .previewDisplayName(data.name)
                        .previewLayout(.fixed(width: 400, height: 450))
                    
                    
                    List {
                        JournalEntryRow(entry: data.entry)
                            .listRowInsets(EdgeInsets())
                            .padding(Spacing.large)
                            .background(CactusColor.background.color)
                    }.environmentObject(SessionStore.mockLoggedIn())
                        .onAppear(perform: {
                            UITableView.appearance().separatorStyle = .none
                            UITableView.appearance().backgroundColor = CactusColor.background
                        })
                        .previewDisplayName(data.name + " (Dark)")
                        .previewLayout(.fixed(width: 400, height: 450))
                        .colorScheme(.dark)
                }
            }
        }
    }
}
