//
//  Home.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct Home_deprecated: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            JournalHome()
        }.navigationBarHidden(true)
            .background(named: .Background)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home_deprecated().environmentObject(SessionStore.mockLoggedIn().setEntries(MockData.getDefaultJournalEntries()))
    }
}
