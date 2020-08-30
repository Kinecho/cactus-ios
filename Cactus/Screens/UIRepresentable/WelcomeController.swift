//
//  Welcome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import UIKit
struct WelcomeController: UIViewControllerRepresentable {
    
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ScreenID.WelcomeVC.getViewController() as! WelcomeViewController
        vc.appSettings = session.settings

        let nav = UINavigationController(rootViewController: vc)
        nav.hidesBarsOnTap = true
        nav.navigationBar.isHidden = true
        
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // nothing to update
    }
    
}

struct Welcome: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
            WelcomeController()
                .edgesIgnoringSafeArea(.vertical)
                .background(named: .Green)
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome().environmentObject(SessionStore.mockLoggedOut())
    }
}
