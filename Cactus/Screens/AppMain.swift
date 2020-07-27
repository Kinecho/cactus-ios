//
//  AppMain.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct AppMain: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack {
            if self.session.authLoaded {
                if self.session.member == nil {
                    Welcome()
                } else {
                    AppTabs()
                }
            } else {
                Loading("Loading...")
            }
        }
    }
}

struct AppMain_Previews: PreviewProvider {
    static var MockAppData = SessionStore.mockLoggedIn()
    static var LoadingAppData = SessionStore()
    static var MockLoggedOut = SessionStore.mockLoggedOut()
    static var previews: some View {
        Group {
            AppMain().environmentObject(self.LoadingAppData).previewDisplayName("Auth Loading")
            AppMain().environmentObject(self.MockAppData).previewDisplayName("Logged In")
            AppMain().environmentObject(self.MockLoggedOut).previewDisplayName("Logged Out")
        }
    }
}
