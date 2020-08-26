//
//  LoggedInApp.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//
import SwiftUI
import NoveFeatherIcons
enum Tab {
    case home
    case journal
    case settings
}

struct AppTabs: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    @State private var selection = Tab.home
    
    let tabImageSize: CGSize = CGSize(width: 30, height: 30)
    
    init() {
        self.updateAppearance()
    }
    
    var homeTitle: LocalizedStringKey {
//        let welcomeBack = self.session.journalEntries.count > 2
//        guard let firstName = self.session.member?.firstName, !isBlank(firstName) else {
//            return welcomeBack ? "Welcome back" : "Welcome"
//        }
//        return welcomeBack ? "Welcome back, \(firstName)" : "Welcome, \(firstName)"
        return StringKey.Home.key
    }
    
    func updateAppearance() {
//        UIScrollView.appearance().backgroundColor = NamedColor.Background.uiColor
        UIScrollView.appearance().backgroundColor = .clear
        
        UITabBar.appearance().unselectedItemTintColor = CactusColor.textMinimized        
                
//        UITableView.appearance().backgroundColor = CactusColor.background
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableView.appearance().showsHorizontalScrollIndicator = false
        UITableView.appearance().tableFooterView = UIView()

//        UINavigationBar.appearance().tintColor = NamedColor.Background.uiColor
//        UINavigationBar.appearance().barTintColor = NamedColor.Background.uiColor
//        UINavigationBar.appearance().backgroundColor = NamedColor.Background.uiColor
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: NamedColor.TextDefault.uiColor
        ]
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                    NavigationView {
                        InsightsHome()
                            .navigationBarTitle(Text(self.homeTitle), displayMode: .large)
                    }
                    .tabItem {
                        Image(uiImage: Feather.getIcon(.home)!)
                            .renderingMode(.template)
                            .resizable()
                            .padding()
                        
                        Text(StringKey.Home)
                    }.tag(Tab.home)
                    
                    NavigationView {
                        JournalFeed()
                        .navigationBarTitle("Journal")
                    }.tabItem {
                        Image(CactusImage.journal.rawValue)
                            .renderingMode(.template)
                            .resizable()
                            .padding()
                        Text("Journal")
                    }.tag(Tab.journal)
                    
                    
                    
                    SettingsHome()
                    .tabItem {
                        Image(uiImage: Feather.getIcon(.settings)!)
                            .renderingMode(.template)
                            .resizable()
                        Text("Settings")
                    }
                    .tag(Tab.settings)
                }
                .onAppear {
                    self.updateAppearance()
                }
                .accentColor(CactusColor.highContrast.color)
                .font(Font(CactusFont.normal))
                
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
//                    CactusButton(nil, .buttonPrimary, icon: Icon.getImage(Feather.IconName.edit)?.image)
                    ComposeNoteButton()
                        .offset(x: -Spacing.medium, y: -Spacing.giant)
                }
            }
        }.environmentObject(session)
        .environmentObject(checkout)
        
    }
}

struct LoggedInApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC)
                .setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Basic User")
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS)
                .setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Plus User")
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC)
                .setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Basic User (Dark)")
                .colorScheme(.dark)
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS)
                .setEntries(MockData.getDefaultJournalEntries()))
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Plus User (Dark)")
                .colorScheme(.dark)
        }
        
        
    }
}
