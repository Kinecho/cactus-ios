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
    
    @State var isOnboarding = false
    
    var body: some View {
        Group {
            if self.session.authLoaded {
                if self.session.member == nil {
                    Welcome().background(named: .Background)
                } else if self.session.journalEntries.isEmpty == false && !isOnboarding {
                    AppTabs().background(named: .Background)
                } else if self.isOnboarding == true || (self.session.journalLoaded && self.session.onboardingEntry != nil) {
//                    HomeEmptyState().onAppear {
//                        self.isOnboarding = true
//                    }
                    PromptContentView(entry: self.session.onboardingEntry!, onPromptDismiss: { entry in
                        self.isOnboarding = false
                    }).onAppear {
                        self.isOnboarding = true
                    }
                    .foregroundColor(named: .TextDefault)
                    .edgesIgnoringSafeArea(.top)
                } else {
                    Loading("Loading...")
                }
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    HStack(alignment: .center) {
                        Spacer()
                        Loading("Loading...")
                        Spacer()
                    }
                    Spacer()
                }
                
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
