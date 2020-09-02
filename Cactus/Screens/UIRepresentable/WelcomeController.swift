//
//  Welcome.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI
import UIKit
import SwiftUIX

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

struct IntroView: View {
    @Binding var showIntro: Bool
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.normal) {
            Image(CactusImage.logoWhite.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 60)
            VStack(alignment: .center, spacing: Spacing.large) {
                Text("Your private journal for greater mental fitness")
                CactusButton("Continue", .buttonPrimary).onTapGesture {
                    self.showIntro = false
                }
            }
        }
        .padding()
        .foregroundColor(named: .White)
    }
}

struct Welcome: View {
    @EnvironmentObject var session: SessionStore
    
    @State var currentPage: Int = 0
    @State var showIntro: Bool = true
    
    var isShowingIntro: Bool {
        self.showIntro && !self.session.isSigningIn
    }
    
    var body: some View {
        ZStack {
            if self.isShowingIntro {
                IntroView(showIntro: self.$showIntro.animation())
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.offset(x: -100, y: 0)))
                    .zIndex(2)
            }
            VStack {
                LoginView()
            }
            .zIndex(1)
            .opacity(self.isShowingIntro ? 0 : 1)
            .animation(Animation.easeIn.delay(0.3))
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Image(CactusImage.background_darkBlobs.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
        )
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome().environmentObject(SessionStore.mockLoggedOut())
    }
}
