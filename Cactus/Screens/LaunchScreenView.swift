//
//  LaunchScreenView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/28/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct LaunchScreenView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let launchStoryboard = UIStoryboard(name: StoryboardID.LaunchScreen.name, bundle: nil)
        let vc = launchStoryboard.instantiateViewController(withIdentifier: ScreenID.LaunchScreen.name)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //no op
    }
    
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .edgesIgnoringSafeArea(.all)
            .background(named: .GreenDarkest)
    }
}
