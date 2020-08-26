//
//  TodayWidgetView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct TodayEntryNotFoundView: View {
    var textColor: Color
    
    var body: some View {
        VStack {
            Text("Uh oh")
                .multilineTextAlignment(.center)
                .font(CactusFont.bold(.title).font)
                .fixedSize(horizontal: false, vertical: true)
            Text("There seems to be an issue finding today's prompt. Please check back a little later.")
                .multilineTextAlignment(.center)
                .font(CactusFont.normal.font)
            .fixedSize(horizontal: false, vertical: true)
            Image(CactusImage.errorBlob.rawValue)
                .resizable()
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
                .offset(x: 0, y: 100)
                .padding(.top, -80)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .foregroundColor(self.textColor)
        .padding()
        .cornerRadius(CornerRadius.normal)
    }
}

struct TodayWidgetView: View {
    @EnvironmentObject var session: SessionStore
    var onTapped: ((JournalEntry) -> Void)?
    
    @State var isAnimating: Bool = false
    
    let textColor: Color = NamedColor.White.color
    
    var todayEntry: JournalEntry? {
        self.session.todayEntry
    }
    
    var todayEntryLoaded: Bool {
        self.session.todayEntryLoaded
    }
    
    var blobsAnimating: Bool {
        return self.todayEntry != nil
    }
    
    func getLoadedWidgetBody(_ entry: JournalEntry) -> some View {
        return JournalEntryRow(
            entry: entry,
            showDetails: {entry in
                self.onTapped?(entry)
            },
            inlineImage: true,
            backgroundColor: .clear,
            textColor: self.textColor
        )
        .onTapGesture {
            self.onTapped?(self.todayEntry!)
        }.onAppear(){
            withAnimation {
                self.isAnimating = true
            }
        }
    }
    
    var animatedBackground: some View {
        return ZStack{
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
                
        }
    }
    
    var body: some View {
        Group {
            if self.todayEntry != nil {
                self.getLoadedWidgetBody(self.todayEntry!)
            } else if self.todayEntryLoaded {
                TodayEntryNotFoundView(textColor: self.textColor)
            } else {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        ActivityIndicator(isAnimating: .constant(true), style: .medium, color: NamedColor.White.color)
                        Text("Loading Today's Prompt")
                        Spacer()
                    }
                    .padding(.all, Spacing.large)
                }
            }
        }
        .background(self.animatedBackground)
        .foregroundColor(named: .White)
        .border(NamedColor.BorderLight.color, width: 1, cornerRadius: CornerRadius.normal, style: RoundedCornerStyle.continuous)
        .shadow(color: Color.black.opacity(0.1), radius: 18, x: 0, y: 15)
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    struct TodayData: Identifiable {
        let id = UUID()
        let session: SessionStore
        let name: String
        
        init(_ name: String, _ session: SessionStore) {
            self.session = session
            self.name = name
        }
    }
    
    static let loadingData = SessionStore.mockLoggedIn()
    static func withData() -> SessionStore {
        let store = SessionStore.mockLoggedIn()
        store.todayEntryLoaded = true
        store.todayEntry = MockData.getUnansweredEntry(isToday: true, blob: 2)
        return store
    }
    
    static let items: [TodayData] = [
        TodayData("Loading", SessionStore.mockLoggedIn()),
        TodayData("No Content", SessionStore.mockLoggedIn(configStore: { store in
            store.todayEntryLoaded = true
            store.todayEntry = nil
        })),
        TodayData("Unansered", SessionStore.mockLoggedIn(configStore: { store in
            store.todayEntryLoaded = true
            store.todayEntry = MockData.getUnansweredEntry(isToday: true, blob: 2)
        }))
    ]
    
    
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.hashValue) { color in
            ForEach(items) { item in
                NavigationView {
                    List {
                        TodayWidgetView()
                            .environmentObject(item.session)
                    }.onAppear(){
                        UITableView.appearance().separatorStyle = .none
                    }
                }
                .previewDisplayName("\(item.name) (\(String(describing: color)))")
                .colorScheme(color)
            }
        }
    }
}
