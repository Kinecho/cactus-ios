//
//  JournalHome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct JournalHomeController: UIViewControllerRepresentable {
    var member: CactusMember
    var user: FirebaseUser?
    var settings: AppSettings?
    
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
    var member: CactusMember
    var user: FirebaseUser?
    var settings: AppSettings?
//    var entries: [JournalEntry]
    var body: some View {
//        JournalHomeController(member: member, user: user, settings: settings)
//            .edgesIgnoringSafeArea(.vertical)
        JournalFeed()
    }
}

struct JournalHome_Previews: PreviewProvider {
    static var mockSession = SessionStore.mockLoggedIn()
    
    static var previews: some View {
        JournalHome(member: mockSession.member!, user: mockSession.user, settings: mockSession.settings)
    }
}
