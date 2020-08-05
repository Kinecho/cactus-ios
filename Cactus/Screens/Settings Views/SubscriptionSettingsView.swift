//
//  SubscriptionSettingsView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct LegacySubscriptoinSettingsViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ManageSubscriptionViewController
    
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> ManageSubscriptionViewController {
        let vc = ScreenID.ManageSubscription.getViewController() as! ManageSubscriptionViewController
        vc.member = session.member
        vc.upgradeCopy = session.settings?.upgradeCopy
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ManageSubscriptionViewController, context: Context) {
        uiViewController.member = session.member
        uiViewController.upgradeCopy = session.settings?.upgradeCopy
    }
}

struct SubscriptionSettingsView: View {
    var body: some View {
        LegacySubscriptoinSettingsViewController()
    }
}

struct SubscriptionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionSettingsView().environmentObject(SessionStore.mockLoggedIn())
    }
}
