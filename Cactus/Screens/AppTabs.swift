//
//  LoggedInApp.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//
import SwiftUI

enum Tab {
    case home
    case journal
    case settings
}

struct AppTabs: View {
    @EnvironmentObject var session: SessionStore
    @State private var selection = Tab.home
    
    let tabImageSize: CGSize = CGSize(width: 30, height: 30)
    
    init() {
//        UITabBar.appearance().tintColor = CactusColor.background
        //        UITabBar.appearance().backgroundColor = CactusColor.green
        UITabBar.appearance().barTintColor = CactusColor.background
        UITabBar.appearance().unselectedItemTintColor = CactusColor.textMinimized
        
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Group {
                Text("Insights/Home")
            }.tabItem {
                Image(CactusImage.pie.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .padding()
                
                Text("Home/Insights")
            }.tag(Tab.home)
            
            NavigationView {
                JournalFeed()
                .navigationBarTitle("Journal")
            }
        
            .tabItem {
                Image(CactusImage.journal.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .padding()
                Text("Journal")
            }.tag(Tab.journal)
            
            
            NavigationView {
                SettingsTable()
                .navigationBarTitle("Settings")
            }.tabItem {
                Image(CactusImage.creditCard.rawValue)
                    .renderingMode(.template)
                    .resizable()
                Text("Settings")
            }
            .tag(Tab.settings)
            
        }
        .accentColor(CactusColor.green.color)
        .font(Font(CactusFont.normal))
        .foregroundColor(CactusColor.green.color)
        .environmentObject(session)
    }
}

struct LoggedInApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC)
                .setEntries(MockData.getDefaultJournalEntries()))
                .previewDisplayName("Basic User")
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS)
                .setEntries(MockData.getDefaultJournalEntries()))
                .previewDisplayName("Plus User")
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .BASIC)
                .setEntries(MockData.getDefaultJournalEntries()))
                .previewDisplayName("Basic User (Dark)")
                .colorScheme(.dark)
            
            AppTabs().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS)
                .setEntries(MockData.getDefaultJournalEntries()))
                .previewDisplayName("Plus User (Dark)")
                .colorScheme(.dark)
        }
        
        
    }
}