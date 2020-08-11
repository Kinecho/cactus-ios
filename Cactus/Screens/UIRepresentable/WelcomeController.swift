//
//  Welcome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct WelcomeController: UIViewControllerRepresentable {
    
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> WelcomeViewController {
        let vc = ScreenID.WelcomeVC.getViewController() as! WelcomeViewController
        return vc
    }
    
    func updateUIViewController(_ uiViewController: WelcomeViewController, context: Context) {
        // nothing to update
    }
    
}

struct Welcome: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            WelcomeController()
                .edgesIgnoringSafeArea(.vertical)
        }
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome().environmentObject(SessionStore.mockLoggedOut())
    }
}
