//
//  LoginView.swift
//  Cactus
//
//  Created by Neil Poulin on 9/1/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct LoginViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var session: SessionStore
    
    func makeUIViewController(context: Context) -> LoginViewController {
        let vc = ScreenID.Login.getViewController() as! LoginViewController
        vc.user = self.session.user
        vc.hideBackground = true
        return vc
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
        uiViewController.user = self.session.user
    }
    
    typealias UIViewControllerType = LoginViewController
}

struct LoginView: View {
    var body: some View {
        LoginViewControllerRepresentable().edgesIgnoringSafeArea(.all)
//        Text("Hello!")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionStore.mockLoggedOut())
    }
}
