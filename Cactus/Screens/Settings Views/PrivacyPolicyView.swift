//
//  PrivacyPolicyView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


/// @Deprecated - use WebView instead
struct PrivacyPolicyWebController: UIViewControllerRepresentable {
    typealias UIViewControllerType = PrivacyPolicyViewController
    
    func makeUIViewController(context: Context) -> PrivacyPolicyViewController {
        let vc = ScreenID.PrivacyPolicy.getViewController() as! PrivacyPolicyViewController
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PrivacyPolicyViewController, context: Context) {
        
    }
}


struct PrivacyPolicyView: View {
    @ObservedObject var webViewStateModel: WebViewStateModel = WebViewStateModel()

    let url = URL(string: "https://cactus.app/privacy-policy?no_nav=true")
    
    var body: some View {
        Group {
            LoadingView(isShowing: .constant(webViewStateModel.loading)) {
                WebView(url: self.url!, webViewStateModel: self.webViewStateModel)
            }
            .navigationBarTitle(Text("Privacy Policy"), displayMode: .inline)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                PrivacyPolicyView()
            }
            .colorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                PrivacyPolicyView()
            }
            .colorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        
    }
}
