//
//  TermsOfServiceView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct TermsOfServiceWebController: UIViewControllerRepresentable {
    typealias UIViewControllerType = TermsOfUseServiceController
    
    func makeUIViewController(context: Context) -> TermsOfUseServiceController {
        let vc = ScreenID.TermsOfService.getViewController() as! TermsOfUseServiceController
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: TermsOfUseServiceController, context: Context) {
        
    }
}


struct TermsOfServiceView: View {
    @ObservedObject var webViewStateModel: WebViewStateModel = WebViewStateModel()
    
    let url = URL(string: "https://cactus.app/terms-of-service?no_nav=true")
    
    var body: some View {
        Group {
            LoadingView(isShowing: .constant(webViewStateModel.loading)) {
                WebView(url: self.url!, webViewStateModel: self.webViewStateModel)
            }
            .navigationBarTitle(Text("Terms of Service"), displayMode: .inline)
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TermsOfServiceView()
            }
            .colorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                TermsOfServiceView()
            }
            .colorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        
    }
}
