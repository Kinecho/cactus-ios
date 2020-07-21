//
//  Home.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            JournalHome(member: session.member!,
                        user: session.user,
                        settings: session.settings)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(SessionStore.mockLoggedIn())
    }
}
