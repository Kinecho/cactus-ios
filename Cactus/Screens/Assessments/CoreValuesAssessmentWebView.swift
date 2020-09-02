//
//  CoreValuesAssessmentWebView.swift
//  Cactus Local
//
//  Created by Neil Poulin on 8/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct CoreValuesControllerRepresentable: UIViewControllerRepresentable {
    var member: CactusMember
    @Binding var showUpgrade: Bool
    var onClose: () -> Void
    
    typealias UIViewControllerType = CoreValuesAssessmentViewController
    
    func makeUIViewController(context: Context) -> CoreValuesAssessmentViewController {
        let vc = ScreenID.CoreValuesAssessment.getViewController() as! CoreValuesAssessmentViewController
        vc.member = self.member
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CoreValuesAssessmentViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        uiViewController.member = self.member
        
    }
    
    class Coordinator: CoreValuesAssessmentViewControllerDelegate {
        let parent: CoreValuesControllerRepresentable
        
        init(_ parent: CoreValuesControllerRepresentable) {
            self.parent = parent
        }
        
        func showUpgrade() {
            parent.showUpgrade = true
        }
        
        func closeAssessment() {
            parent.onClose()
        }
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


struct CoreValuesAssessmentWebView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var checkout: CheckoutStore
    @State var showUpgrade: Bool = false
    
    var onClose: () -> Void
    
    var body: some View {
        Group {
            if self.session.member != nil {
                CoreValuesControllerRepresentable(member: self.session.member!, showUpgrade: self.$showUpgrade, onClose: self.onClose)
            } else {
                Text("Please log in to take the Core Values quiz.")
            }
        }.sheet(isPresented: self.$showUpgrade) {
            PricingView().environmentObject(self.session)
                .environmentObject(self.checkout)
        }
    }
}

struct CoreValuesAssessmentWebView_Previews: PreviewProvider {
    static var previews: some View {
        CoreValuesAssessmentWebView(onClose: {
            //no op
        }).environmentObject(SessionStore.mockLoggedIn())
            .environmentObject(CheckoutStore.mock())
    }
}
