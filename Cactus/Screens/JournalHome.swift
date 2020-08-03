//
//  JournalHome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalHomeController: UIViewControllerRepresentable {
    @EnvironmentObject var session: SessionStore
    var member: CactusMember? {
        session.member
    }
    var user: FirebaseUser? {
        session.user
    }
    var settings: AppSettings? {
        session.settings
    }
    
    func makeUIViewController(context: Context) -> JournalHomeViewController {
        let vc = ScreenID.JournalHome.getViewController() as! JournalHomeViewController
        vc.member = member
        vc.user = user
        vc.appSettings = settings
        return vc
    }
    
    func updateUIViewController(_ uiViewController: JournalHomeViewController, context: Context) {
        uiViewController.member = member
        uiViewController.user = user
        uiViewController.appSettings = settings
    }
}

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
