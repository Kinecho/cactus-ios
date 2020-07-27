//
//  PricingView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PricingController: UIViewControllerRepresentable {
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> PricingViewController {
        let vc = ScreenID.Pricing.getViewController() as! PricingViewController
        vc.appSettings = session.settings
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PricingViewController, context: Context) {
        uiViewController.appSettings = session.settings
    }
}

struct PricingView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        PricingController()
            .edgesIgnoringSafeArea(.vertical)
            .environmentObject(session)
    }
}

struct PricingView_Previews: PreviewProvider {
    static var previews: some View {
        PricingView().environmentObject(SessionStore.mockLoggedIn())
    }
}
