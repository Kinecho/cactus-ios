//
//  ProfileSettingsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct LegacyProfileSettingsView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ProfileSettingsViewController
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> ProfileSettingsViewController {
        let vc = ScreenID.ProfileSettings.getViewController() as! ProfileSettingsViewController
        vc.member = session.member
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ProfileSettingsViewController, context: Context) {
        uiViewController.member = session.member
    }
}

struct ProfileSettingsView: View {
    @EnvironmentObject var session: SessionStore
    
    
    var body: some View {
        LegacyProfileSettingsView().background(named: .Background)
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ProfileSettingsView()
                    .navigationBarTitle("Profile")
            }
                .background(named: .Background)
                .environmentObject(SessionStore.mockLoggedIn())
            
            
            NavigationView {
                ProfileSettingsView().navigationBarTitle("Profile")
            }.environmentObject(SessionStore.mockLoggedIn())
                .background(named: .Background)
                .colorScheme(.dark)
        }
    }
}
