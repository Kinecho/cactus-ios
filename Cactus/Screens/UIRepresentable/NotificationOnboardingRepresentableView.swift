//
//  NotificationOnboardingRepresentableView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct NotificationOnboardingRepresentableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> NotificationOnboardingViewController {
        let vc = ScreenID.notificationOnboarding.getViewController() as! NotificationOnboardingViewController
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NotificationOnboardingViewController, context: Context) {
        //
    }
    
    typealias UIViewControllerType = NotificationOnboardingViewController
}

struct NotificationOnboardingRepresentableView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationOnboardingRepresentableView()
    }
}
