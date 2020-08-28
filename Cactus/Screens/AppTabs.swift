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
    let maxWidth: CGFloat = 700
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
    
    var homeTabView: AnyView {
        return Group {
            if self.session.journalEntries.isEmpty == false {
                NavigationView {
                    InsightsHome()
                        .navigationBarTitle(Text(self.homeTitle), displayMode: .large)
                }
            } else {
                HomeEmptyState()
            }
        }
            .maxWidth(self.maxWidth)
        .onDisappear {
            Vibration.light.vibrate()
        }
        .tabItem {
            Image(uiImage: Feather.getIcon(.home)!)
                .renderingMode(.template)
                .resizable()
                .padding()
            
            Text(StringKey.Home)
        }
        .tag(Tab.home)
        .eraseToAnyView()
    }
    
    var journalTabView: AnyView {
        return Group {
            if self.session.journalEntries.isEmpty == false {
                NavigationView {
                    JournalFeed()
                    .navigationBarTitle("Journal")
                }
            } else {
                JournalEmptyStateView()
            }
        }
            .maxWidth(self.maxWidth)
        .onDisappear {
            Vibration.light.vibrate()
        }
        .tabItem {
            Image(CactusImage.journal.rawValue)
                .renderingMode(.template)
                .resizable()
                .padding()
            Text("Journal")
        }
        .tag(Tab.journal)
        .eraseToAnyView()
    }
    
    var settingsTabView: AnyView {
        return SettingsHome()
        .onDisappear {
            Vibration.light.vibrate()
        }
        .tabItem {
            Image(uiImage: Feather.getIcon(.settings)!)
                .renderingMode(.template)
                .resizable()
            Text("Settings")
        }
        .tag(Tab.settings)
        .eraseToAnyView()

    }
    
    var appTabView: some View {
        return TabView(selection: self.$selection) {
            self.homeTabView
            self.journalTabView
            self.settingsTabView
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(CactusColor.highContrast.color)
        .font(Font(CactusFont.normal))
                    
    }
    
    var composeNoteView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ComposeNoteButton()
                    .offset(x: -Spacing.medium, y: -Spacing.giant)
            }
        }
    }
    
    var body: some View {
//        NavigationView {
            ZStack {
                self.appTabView
                self.composeNoteView
            }
//        }
        .onAppear {
            self.updateAppearance()
        }
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
