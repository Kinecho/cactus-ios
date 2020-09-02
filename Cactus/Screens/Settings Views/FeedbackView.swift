//
//  FeedbackView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct LegacyFeedbackViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = FeedbackViewController
    
    func makeUIViewController(context: Context) -> FeedbackViewController {
        let vc = ScreenID.SendFeedback.getViewController() as! FeedbackViewController
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: FeedbackViewController, context: Context) {
        
    }
}

struct FeedbackView: View {
    var body: some View {
        LegacyFeedbackViewController()
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
