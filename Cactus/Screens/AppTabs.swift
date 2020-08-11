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
    
    func updateAppearance() {
//        UITabBar.appearance().barTintColor = CactusColor.greenRoyal
        UITabBar.appearance().unselectedItemTintColor = CactusColor.textMinimized
        UIScrollView.appearance().backgroundColor = CactusColor.background
        UITabBar.appearance().backgroundColor = CactusColor.background
        UITableView.appearance().backgroundColor = CactusColor.background
//        UITableViewCell.appearance().backgroundColor = CactusColor.background
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: NamedColor.TextDefault.uiColor
        ]
        
        UINavigationBar.appearance().backgroundColor = NamedColor.Background.uiColor
    }
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                InsightsHome()
                    .navigationBarTitle("Home")
            }
            .tabItem {
                Image(uiImage: Feather.getIcon(.home)!)
                    .renderingMode(.template)
                    .resizable()
                    .padding()
                
                Text("Home")
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
        .accentColor(NamedColor.Magenta.color)
        .font(Font(CactusFont.normal))
        
        .environmentObject(session)
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
