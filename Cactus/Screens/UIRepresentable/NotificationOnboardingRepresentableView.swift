//
//  NotificationOnboardingRepresentableView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct NotificationOnboardingRepresentableView: UIViewControllerRepresentable {
    var status: UNAuthorizationStatus?
    
    func makeUIViewController(context: Context) -> NotificationOnboardingViewController {
        let vc = ScreenID.notificationOnboarding.getViewController() as! NotificationOnboardingViewController
        vc.status = self.status
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NotificationOnboardingViewController, context: Context) {
        uiViewController.status = self.status
    }
    
    typealias UIViewControllerType = NotificationOnboardingViewController
}

struct NotificationOnboardingRepresentableView_Previews: PreviewProvider {
    static let statuses: [(name: String, status: UNAuthorizationStatus)] = [
        (name: "Authorized", status: .authorized),
        (name: "Denied", status: .denied),
        (name: "Not Determined", status: .notDetermined),
        (name: "Provisional", status: .provisional)
    ]
    static let colors: [ColorScheme] = [.light, .dark]
    
    static var previews: some View {
        Group {
            ForEach(colors, id: \.hashIdentifiable) {color in
                ForEach(statuses, id: \.name) { item in
                    NotificationOnboardingRepresentableView(status: item.status)
                        .previewDisplayName("\(item.name) - \(String(describing: color))")
                        .edgesIgnoringSafeArea(.vertical)
                        .colorScheme(color)
                }
            }
            
        }
    }
}
