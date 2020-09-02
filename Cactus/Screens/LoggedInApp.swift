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
                Image(systemName: "list.dash")
                Text("Home")
            }
            .environmentObject(session)
        }
    }
}

struct LoggedInApp_Previews: PreviewProvider {
    static var previews: some View {
        AppTabs().environmentObject(SessionStore.mockLoggedIn())
    }
}
