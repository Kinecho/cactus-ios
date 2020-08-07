//
//  NotificationsOnboardingView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct NotificationsOnboardingView: View {
    var body: some View {
        NotificationOnboardingRepresentableView().edgesIgnoringSafeArea(.vertical)
    }
}

struct NotificationsOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsOnboardingView()
    }
}
