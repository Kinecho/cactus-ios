//
//  HelpView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct LegacyHelpViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = HelpViewController
    
    func makeUIViewController(context: Context) -> HelpViewController {
        let vc = ScreenID.AskQuestions.getViewController() as! HelpViewController
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: HelpViewController, context: Context) {
        
    }
}

struct HelpView: View {
    var body: some View {
        LegacyHelpViewController()
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
