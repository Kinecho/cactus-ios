//
//  JournalHome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct JournalHome: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        JournalFeed()
            .navigationBarHidden(true)
    }
}

struct JournalHome_Previews: PreviewProvider {
    static var mockSession = SessionStore.mockLoggedIn().setEntries(MockData.getDefaultJournalEntries())
    
    static var previews: some View {
        JournalHome().environmentObject(mockSession).environmentObject(CheckoutStore.mock())
    }
}
