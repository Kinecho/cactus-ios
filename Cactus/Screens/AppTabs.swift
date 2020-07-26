//
//  LoggedInApp.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct AppTabs: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        TabView {
            Home().tabItem {
                Image(CactusImage.journal.rawValue)
                Text("Journal")
            }            
            .environmentObject(session)
        }
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
        }
        
        
    }
}
