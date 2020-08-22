//
//  TodayWidgetView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct TodayWidgetView: View {
    @EnvironmentObject var session: SessionStore
    var onTapped: ((JournalEntry) -> Void)?
    
    @State var isAnimating: Bool = false
    
    var todayEntry: JournalEntry? {
        self.session.journalFeedDataSource?.todayData?.getJournalEntry()
    }
    
    var todayEntryLoaded: Bool {
        self.session.journalFeedDataSource?.todayLoaded ?? false
    }
    
    var blobsAnimating: Bool {
        return self.todayEntry != nil
    }
    
    var body: some View {
        Group {
            if self.todayEntry != nil {
                JournalEntryRow(entry: self.todayEntry!, showDetails: {entry in
                    self.onTapped?(entry)
                }, inlineImage: true, backgroundColor: .clear).onTapGesture {
                    self.onTapped?(self.todayEntry!)
                }.onAppear(){
                    withAnimation {
                        self.isAnimating = true
                    }
                    
                }
            } else if self.todayEntryLoaded {
                VStack {
                    Text("Uh oh")
                        .multilineTextAlignment(.center)
                        .font(CactusFont.bold(.title).font)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("There seems to be an issue finding today's prompt. Please check back a little later.")
                        .multilineTextAlignment(.center)
                        .font(CactusFont.normal.font)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .foregroundColor(named: .White)
                .padding()
                .cornerRadius(CornerRadius.normal)
                
            } else {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        ActivityIndicator(isAnimating: .constant(true), style: .medium, color: NamedColor.White.color)
                        Text("Loading Today's Prompt")
                        Spacer()
                    }
                    .padding(.all, Spacing.large)
                    .cornerRadius(CornerRadius.normal)
                }
            }
        }
        .background(
            ZStack{
                NamedColor.TodayWidgetBackground.color
                    .overlay(GeometryReader{ geo in
                        ZStack {
                            Image(CactusImage.todayBlob1.rawValue)
                                        .resizable()
                                            .frame(width: geo.size.width, height: 400)
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.black)
                                .scaleEffect(1.1)
                                        .opacity(0.03)
                                .offset(x: -geo.size.width * 3/4, y: -geo.size.height/3)
                                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0), anchor: UnitPoint(x: 0.1, y: 0.5))
                                        .animation(self.isAnimating ? Animation.easeInOut(duration: 80).repeatForever(autoreverses: false) : nil)

                                    Image(CactusImage.todayBlob2.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.black)
                                        .scaleEffect(1.1)
                                        .opacity(0.03)
                                        .offset(x: geo.size.width * 2/3, y: geo.size.height * 1/3)
                                        .rotationEffect(Angle(degrees: self.isAnimating ? -360 : 0), anchor: UnitPoint(x: 0.8, y: 0.5))
                                        .animation(self.isAnimating ? Animation.easeInOut(duration: 75).repeatForever(autoreverses: false) : nil)
                        }
                    })
                    
            })
        .foregroundColor(named: .White)
        .border(NamedColor.BorderLight.color, cornerRadius: CornerRadius.normal, style: .continuous, width: 1)
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    static let loadingData = SessionStore.mockLoggedIn()
    static func withData() -> SessionStore {
        let store = SessionStore.mockLoggedIn()
        let todayData = JournalEntryData(promptId: nil, memberId: store.member?.id ?? "test", journalDate: Date())
//        todayData.wontLoad = true
        store.journalFeedDataSource?.todayData = todayData
        return store
    }
    static var previews: some View {
        Group {
            TodayWidgetView()
                .environmentObject(loadingData)
                .previewDisplayName("Loading (Light))")
                .colorScheme(.light)
            
            TodayWidgetView()
                .environmentObject(withData())
                .previewDisplayName("Unanswered Prompt (Light))")
                .colorScheme(.light)
        }
        
    }
}
