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
        //blah
    }
    
//    var body: some View {
//        Text("Welcome to Cactus!")
//    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeController().environmentObject(SessionStore.mockLoggedOut())
    }
}
