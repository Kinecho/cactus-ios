//
//  SettingsView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct SettingsTable: UIViewControllerRepresentable {
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
    
    func makeUIViewController(context: Context) -> SettingsTableViewController {
        let vc = ScreenID.settingsTable.getViewController() as! SettingsTableViewController
        vc.member = member
//        vc.user = user
        vc.settings = settings
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SettingsTableViewController, context: Context) {
        uiViewController.member = member
        uiViewController.settings = settings
    }
}

struct SettingsTable_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsTable().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .previewDisplayName("Plus User")
            
            SettingsTable().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .previewDisplayName("Basic User")
            
            SettingsTable().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .previewDisplayName("Plus User (Dark)")
                .colorScheme(.dark)
            
            SettingsTable().environmentObject(SessionStore.mockLoggedIn(tier: .PLUS))
                .previewDisplayName("Basic User (Dark)")
                .colorScheme(.dark)
        }
        
        
    }
}
