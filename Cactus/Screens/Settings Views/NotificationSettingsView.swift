//
//  NotificationSettingsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct LegacyNotificationSettingsView: UIViewControllerRepresentable {
    typealias UIViewControllerType = NotificationsTableViewController
    
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> NotificationsTableViewController {
        let vc = ScreenID.notificationsScreen.getViewController() as! NotificationsTableViewController
        vc.member = session.member
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NotificationsTableViewController, context: Context) {
        uiViewController.member = session.member
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        LegacyNotificationSettingsView()
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView().environmentObject(SessionStore.mockLoggedIn())
    }
}
