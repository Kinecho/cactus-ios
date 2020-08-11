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
    @EnvironmentObject var checkout: CheckoutStore
    
    var body: some View {
        VStack {
            if self.session.authLoaded {
                if self.session.member == nil {
                    Welcome().background(named: .Background)
                } else {
                    AppTabs().background(named: .Background)
                }
            } else {
                Loading("Loading...")
            }
        }.background(named: .Background)
    }
}

struct AppMain_Previews: PreviewProvider {
    static var MockAppData = SessionStore.mockLoggedIn()
    static var LoadingAppData = SessionStore()
    static var MockLoggedOut = SessionStore.mockLoggedOut()
    static var previews: some View {
        Group {
            AppMain().environmentObject(self.LoadingAppData)
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Auth Loading")
            
            AppMain().environmentObject(self.LoadingAppData)
            .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
            .previewDisplayName("Auth Loading (Dark)")
            
            AppMain().environmentObject(self.MockAppData)
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Logged In")
            
            AppMain().environmentObject(self.MockAppData)
            .environmentObject(CheckoutStore.mock())
                .colorScheme(.dark)
            .previewDisplayName("Logged In (Dark)")
                
            AppMain().environmentObject(self.MockLoggedOut)
                .environmentObject(CheckoutStore.mock())
                .previewDisplayName("Logged Out")
                
        }
    }
}
